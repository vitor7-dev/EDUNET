using System.Security.Claims;
using internetapi.Data;
using internetapi.Dtos;
using internetapi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace internetapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly TokenService _tokens;

        public AuthController(AppDbContext db, TokenService tokens) { _db = db; _tokens = tokens; }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest req)
        {
            try
            {
                var hash = SenhaHasher.Gerar(req.Senha);
                var ids = await _db.Database
                    .SqlQuery<int>($"EXEC dbo.sp_CadastrarUsuario {req.Nome.Trim()}, {req.Email.Trim().ToLower()}, {hash}, {req.Telefone}, {req.CPF}")
                    .ToListAsync();
                var usuario = await _db.Usuarios.FindAsync(ids[0]);
                return Ok(new AuthResponse(_tokens.Gerar(usuario!), ParaDto(usuario!)));
            }
            catch (SqlException ex) when (ex.Number >= 50000)
            {
                return BadRequest(new { mensagem = ex.Message });
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest req)
        {
            var email = req.Email.Trim().ToLower();
            var u = await _db.Usuarios.FirstOrDefaultAsync(x => x.Email == email && x.Ativo);
            // Mesma mensagem para e-mail inexistente e senha errada (nao revela qual falhou).
            if (u == null || !SenhaHasher.Verificar(req.Senha, u.SenhaHash))
                return Unauthorized(new { mensagem = "E-mail ou senha invalidos." });

            return Ok(new AuthResponse(_tokens.Gerar(u), ParaDto(u)));
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> Me()
        {
            var id = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var u = await _db.Usuarios.FindAsync(id);
            return u == null ? Unauthorized() : Ok(ParaDto(u));
        }

        private static UsuarioDto ParaDto(Models.Usuario u) => new(u.IdUsuario, u.Nome, u.Email, u.Perfil, u.Telefone);
    }
}
