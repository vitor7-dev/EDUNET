using System.Security.Claims;
using internetapi.Data;
using internetapi.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace internetapi.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class ChamadosController : ControllerBase
    {
        private static readonly string[] StatusValidos = { "Aberto", "EmAndamento", "Resolvido" };
        private readonly AppDbContext _db;
        public ChamadosController(AppDbContext db) => _db = db;

        private int UsuarioId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet("meus")]
        public async Task<IActionResult> Meus() =>
            Ok(await _db.Chamados.AsNoTracking()
                .Where(c => c.IdUsuario == UsuarioId)
                .OrderByDescending(c => c.DataAbertura).ToListAsync());

        [HttpPost]
        public async Task<IActionResult> Abrir([FromBody] ChamadoRequest req)
        {
            try
            {
                var ids = await _db.Database
                    .SqlQuery<int>($"EXEC dbo.sp_AbrirChamado {UsuarioId}, {req.Assunto.Trim()}, {req.Descricao.Trim()}")
                    .ToListAsync();
                return Ok(new { idChamado = ids[0], mensagem = "Chamado aberto. Em breve nossa equipe retorna." });
            }
            catch (SqlException ex) when (ex.Number >= 50000)
            {
                return BadRequest(new { mensagem = ex.Message });
            }
        }

        [Authorize(Roles = "Admin")]
        [HttpGet]
        public async Task<IActionResult> Todos() =>
            Ok(await _db.Chamados.AsNoTracking().OrderByDescending(c => c.DataAbertura).ToListAsync());

        [Authorize(Roles = "Admin")]
        [HttpPut("{id:int}/status")]
        public async Task<IActionResult> AtualizarStatus(int id, [FromBody] StatusRequest req)
        {
            if (!StatusValidos.Contains(req.Status))
                return BadRequest(new { mensagem = "Status invalido." });
            var c = await _db.Chamados.FindAsync(id);
            if (c == null) return NotFound(new { mensagem = "Chamado nao encontrado." });
            c.Status = req.Status;
            await _db.SaveChangesAsync(); // trigger preenche DataFechamento
            return Ok(c);
        }
    }
}
