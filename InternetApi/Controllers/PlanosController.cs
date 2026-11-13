using internetapi.Data;
using internetapi.Dtos;
using internetapi.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace internetapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlanosController : ControllerBase
    {
        private readonly AppDbContext _db;
        public PlanosController(AppDbContext db) => _db = db;

        [HttpGet]
        public async Task<IActionResult> Listar() =>
            Ok(await _db.Planos.AsNoTracking().Where(p => p.Ativo).OrderBy(p => p.VelocidadeMbps).ToListAsync());

        // Admin: lista tambem os planos inativos
        [Authorize(Roles = "Admin")]
        [HttpGet("todos")]
        public async Task<IActionResult> ListarTodos() =>
            Ok(await _db.Planos.AsNoTracking().OrderBy(p => p.VelocidadeMbps).ToListAsync());

        [HttpGet("{id:int}")]
        public async Task<IActionResult> Obter(int id)
        {
            var p = await _db.Planos.AsNoTracking().FirstOrDefaultAsync(x => x.IdPlano == id);
            return p == null ? NotFound(new { mensagem = "Plano nao encontrado." }) : Ok(p);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public async Task<IActionResult> Criar([FromBody] PlanoRequest r)
        {
            var p = new Plano { NomePlano = r.NomePlano, VelocidadeMbps = r.VelocidadeMbps, Preco = r.Preco, Descricao = r.Descricao, Ativo = r.Ativo };
            _db.Planos.Add(p);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(Obter), new { id = p.IdPlano }, p);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id:int}")]
        public async Task<IActionResult> Atualizar(int id, [FromBody] PlanoRequest r)
        {
            var p = await _db.Planos.FindAsync(id);
            if (p == null) return NotFound(new { mensagem = "Plano nao encontrado." });
            p.NomePlano = r.NomePlano; p.VelocidadeMbps = r.VelocidadeMbps; p.Preco = r.Preco;
            p.Descricao = r.Descricao; p.Ativo = r.Ativo;
            await _db.SaveChangesAsync(); // dispara trg_Plano_AuditoriaPreco se o preco mudou
            return Ok(p);
        }
    }
}
