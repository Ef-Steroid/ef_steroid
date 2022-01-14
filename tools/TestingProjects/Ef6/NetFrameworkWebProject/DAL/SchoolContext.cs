using System.Data.Entity;
using System.Data.Entity.Migrations;
using System.Data.Entity.ModelConfiguration.Conventions;
using MySql.Data.Entity;
using NetFrameworkWebProject.Migrations;
using NetFrameworkWebProject.Models;

namespace NetFrameworkWebProject.DAL
{
    [DbConfigurationType(typeof(MySqlEFConfiguration))]
    public class SchoolContext : DbContext
    {
        public DbSet<Student> Students { get; set; }

        public SchoolContext() : base("SchoolContext")
        {
            var configuration = new Configuration();
            var migrator = new DbMigrator(configuration);
            migrator.Update();
        }


        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Conventions.Remove<PluralizingTableNameConvention>();
        }
    }
}
