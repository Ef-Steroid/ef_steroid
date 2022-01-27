
using System;
using System.Data.Entity;
using System.Data.Entity.Migrations;
using System.Linq;

namespace NetFrameworkWebProject.Migrations
{
    internal sealed class Configuration : DbMigrationsConfiguration<NetFrameworkWebProject.DAL.SchoolContext>
    {
        public Configuration()
        {
            AutomaticMigrationsEnabled = false;
        }
    } 
}