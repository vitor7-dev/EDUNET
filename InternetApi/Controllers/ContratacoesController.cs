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
    public class ContratacoesController : ControllerBase
    {
        private readonly AppDbContext _db;
        public ContratacoesController(AppDbContext db) => _db = db;

        private int UsuarioId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet("minhas")]
        public async Task<IActionResult> Minhas()
        {
            var lista = await _db.Contratacoes.AsNoTracking()
                .Where(c => c.IdUsuario == UsuarioId)
                .OrderByDescending(c => c.DataContratacao)
                .Select(c => new
                {
                    c.IdContratacao, c.IdPlano, c.Endereco, c.Status, c.DataContratacao, c.DataCancelamento,
                    plano = new { c.Plano!.NomePlano, c.Plano.VelocidadeMbps, c.Plano.Preco }
                }).ToListAsync();
            return Ok(lista);
        }

        // Usa a procedure sp_ContratarPlano (regras de negocio e transacao no banco)
        [HttpPost]
        public async Task<IActionResult> Contratar([FromBody] ContratarRequest req)
        {
            try
            {
                var ids = await _db.Database
                    .SqlQuery<int>($"EXEC dbo.sp_ContratarPlano {UsuarioId}, {req.IdPlano}, {req.Endereco.Trim()}")
                    .ToListAsync();
                return Ok(new { idContratacao = ids[0], mensagem = "Plano contratado com sucesso!" });
            }
            catch (SqlException ex) when (ex.Number >= 50000)
            {
                return BadRequest(new { mensagem = ex.Message });
            }
        }

        [HttpPost("{id:int}/cancelar")]
        public async Task<IActionResult> Cancelar(int id)
        {
            try
            {
                await _db.Database.SqlQuery<int>($"EXEC dbo.sp_CancelarContratacao {id}, {UsuarioId}").ToListAsync();
                return Ok(new { mensagem = "Contratacao cancelada." });
            }
            catch (SqlException ex) when (ex.Number >= 50000)
            {
                return BadRequest(new { mensagem = ex.Message });
            }
        }
    }
}
