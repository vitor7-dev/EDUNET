using internetapi.Models;
using Microsoft.EntityFrameworkCore;

namespace internetapi.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Usuario> Usuarios => Set<Usuario>();
        public DbSet<Plano> Planos => Set<Plano>();
        public DbSet<Contratacao> Contratacoes => Set<Contratacao>();
        public DbSet<Contato> Contatos => Set<Contato>();
        public DbSet<ChamadoSuporte> Chamados => Set<ChamadoSuporte>();

        protected override void OnModelCreating(ModelBuilder b)
        {
            // Tabelas com triggers precisam ser declaradas: o EF deixa de usar OUTPUT
            // e evita erro ao salvar.
            b.Entity<Contratacao>().ToTable(t =>
            {
                t.HasTrigger("trg_Contratacao_Auditoria");
                t.HasTrigger("trg_Contratacao_Cancelamento");
            });
            b.Entity<ChamadoSuporte>().ToTable(t => t.HasTrigger("trg_Chamado_Fechamento"));
            b.Entity<Plano>().ToTable(t => t.HasTrigger("trg_Plano_AuditoriaPreco"));

            b.Entity<Usuario>().HasIndex(u => u.Email).IsUnique();
            b.Entity<Contratacao>().HasOne(c => c.Plano).WithMany().HasForeignKey(c => c.IdPlano);
        }
    }
}
