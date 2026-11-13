using System.ComponentModel.DataAnnotations;

namespace internetapi.Dtos
{
    public class RegisterRequest
    {
        [Required(ErrorMessage = "Informe o nome."), StringLength(100, MinimumLength = 3)] public string Nome { get; set; } = "";
        [Required(ErrorMessage = "Informe o e-mail."), EmailAddress(ErrorMessage = "E-mail invalido."), StringLength(150)] public string Email { get; set; } = "";
        [Required(ErrorMessage = "Informe a senha."), StringLength(60, MinimumLength = 6, ErrorMessage = "A senha deve ter de 6 a 60 caracteres.")] public string Senha { get; set; } = "";
        [StringLength(20)] public string? Telefone { get; set; }
        [RegularExpression(@"^\d{11}$", ErrorMessage = "CPF deve ter 11 numeros.")] public string? CPF { get; set; }
    }

    public class LoginRequest
    {
        [Required, EmailAddress] public string Email { get; set; } = "";
        [Required] public string Senha { get; set; } = "";
    }

    public record UsuarioDto(int Id, string Nome, string Email, string Perfil, string? Telefone);
    public record AuthResponse(string Token, UsuarioDto Usuario);

    public class ContratarRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "Plano invalido.")] public int IdPlano { get; set; }
        [Required(ErrorMessage = "Informe o endereco de instalacao."), StringLength(200, MinimumLength = 8)] public string Endereco { get; set; } = "";
    }

    public class ChamadoRequest
    {
        [Required(ErrorMessage = "Informe o assunto."), StringLength(100, MinimumLength = 3)] public string Assunto { get; set; } = "";
        [Required(ErrorMessage = "Descreva o problema."), StringLength(500, MinimumLength = 10)] public string Descricao { get; set; } = "";
    }

    public class StatusRequest { [Required] public string Status { get; set; } = ""; }

    public class PlanoRequest
    {
        [Required, StringLength(60)] public string NomePlano { get; set; } = "";
        [Range(1, 100000)] public int VelocidadeMbps { get; set; }
        [Range(0.01, 100000)] public decimal Preco { get; set; }
        [StringLength(300)] public string? Descricao { get; set; }
        public bool Ativo { get; set; } = true;
    }

    public class ContatoRequest
    {
        [Required, StringLength(100, MinimumLength = 3)] public string Nome { get; set; } = "";
        [Required, EmailAddress] public string Email { get; set; } = "";
        [StringLength(20)] public string? Telefone { get; set; }
        public int? IdPlano { get; set; }
        [StringLength(300)] public string? Mensagem { get; set; }
    }

    // Resultados de procedures
    public class PlanoRanking { public string NomePlano { get; set; } = ""; public int Total { get; set; } }
    public class ResumoRelatorio
    {
        public int TotalClientes { get; set; }
        public int ContratacoesAtivas { get; set; }
        public int TotalContatos { get; set; }
        public int ChamadosAbertos { get; set; }
    }
}
