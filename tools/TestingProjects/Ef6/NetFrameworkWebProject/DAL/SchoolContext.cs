using System.Data.Entity;
using System.Data.Entity.ModelConfiguration.Conventions;
using NetFrameworkWebProject.Models;

namespace NetFrameworkWebProject.DAL
{
    public class SchoolContext : DbContext
    {
        public DbSet<Student> Students { get; set; }

        public SchoolContext() : base("SchoolContext")
        {

        }


        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Conventions.Remove<PluralizingTableNameConvention>();
        }
    }
}
