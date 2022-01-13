using System.Data.Entity;
using System.Data.Entity.ModelConfiguration.Conventions;
using MySql.Data.Entity;
using NetFrameworkWebProject.Models;

namespace NetFrameworkWebProject.DAL
{
    [DbConfigurationType(typeof(MySqlEFConfiguration))]
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
