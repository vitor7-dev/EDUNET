using internetapi.Data;
using internetapi.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace internetapi.Controllers
{
    [ApiController]
    [Authorize(Roles = "Admin")]
    [Route("api/[controller]")]
    public class RelatoriosController : ControllerBase
    {
        private readonly AppDbContext _db;
        public RelatoriosController(AppDbContext db) => _db = db;

        [HttpGet("resumo")]
        public async Task<IActionResult> Resumo()
        {
            var r = await _db.Database.SqlQuery<ResumoRelatorio>($"EXEC dbo.sp_RelatorioResumo").ToListAsync();
            return Ok(r.First());
        }

        [HttpGet("planos-mais-contratados")]
        public async Task<IActionResult> PlanosMaisContratados() =>
            Ok(await _db.Database.SqlQuery<PlanoRanking>($"EXEC dbo.sp_RelatorioPlanosMaisContratados").ToListAsync());
    }
}
