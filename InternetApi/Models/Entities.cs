using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace internetapi.Models
{
    [Table("Usuario")]
    public class Usuario
    {
        [Key] public int IdUsuario { get; set; }
        [Required, MaxLength(100)] public string Nome { get; set; } = "";
        [Required, MaxLength(150)] public string Email { get; set; } = "";
        [Required, MaxLength(255)] public string SenhaHash { get; set; } = "";
        [MaxLength(20)] public string? Telefone { get; set; }
        [MaxLength(11)] public string? CPF { get; set; }
        [Required, MaxLength(10)] public string Perfil { get; set; } = "Cliente";
        public bool Ativo { get; set; } = true;
        public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    }

    [Table("Plano")]
    public class Plano
    {
        [Key] public int IdPlano { get; set; }
        [Required, MaxLength(60)] public string NomePlano { get; set; } = "";
        public int VelocidadeMbps { get; set; }
        [Column(TypeName = "decimal(10,2)")] public decimal Preco { get; set; }
        [MaxLength(300)] public string? Descricao { get; set; }
        public bool Ativo { get; set; } = true;
    }

    [Table("Contratacao")]
    public class Contratacao
    {
        [Key] public int IdContratacao { get; set; }
        public int IdUsuario { get; set; }
        public int IdPlano { get; set; }
        [Required, MaxLength(200)] public string Endereco { get; set; } = "";
        [Required, MaxLength(15)] public string Status { get; set; } = "Ativa";
        public DateTime DataContratacao { get; set; }
        public DateTime? DataCancelamento { get; set; }
        public Plano? Plano { get; set; }
    }

    [Table("Contato")]
    public class Contato
    {
        [Key] public int IdContato { get; set; }
        [Required, MaxLength(100)] public string Nome { get; set; } = "";
        [Required, MaxLength(150)] public string Email { get; set; } = "";
        [MaxLength(20)] public string? Telefone { get; set; }
        public int? IdPlano { get; set; }
        [MaxLength(300)] public string? Mensagem { get; set; }
        public DateTime DataEnvio { get; set; } = DateTime.UtcNow;
    }

    [Table("ChamadoSuporte")]
    public class ChamadoSuporte
    {
        [Key] public int IdChamado { get; set; }
        public int IdUsuario { get; set; }
        [Required, MaxLength(100)] public string Assunto { get; set; } = "";
        [Required, MaxLength(500)] public string Descricao { get; set; } = "";
        [Required, MaxLength(15)] public string Status { get; set; } = "Aberto";
        public DateTime DataAbertura { get; set; } = DateTime.UtcNow;
        public DateTime? DataFechamento { get; set; }
    }
}
