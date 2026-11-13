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
    public class ContatosController : ControllerBase
    {
        private readonly AppDbContext _db;
        public ContatosController(AppDbContext db) => _db = db;

        // Publico: formulario de contato do site (PIM III)
        [HttpPost]
        public async Task<IActionResult> Criar([FromBody] ContatoRequest r)
        {
            var c = new Contato { Nome = r.Nome.Trim(), Email = r.Email.Trim(), Telefone = r.Telefone, IdPlano = r.IdPlano, Mensagem = r.Mensagem };
            _db.Contatos.Add(c);
            await _db.SaveChangesAsync();
            return Ok(new { mensagem = "Mensagem enviada com sucesso!" });
        }

        [Authorize(Roles = "Admin")]
        [HttpGet]
        public async Task<IActionResult> Listar() =>
            Ok(await _db.Contatos.AsNoTracking().OrderByDescending(c => c.DataEnvio).ToListAsync());
    }
}
