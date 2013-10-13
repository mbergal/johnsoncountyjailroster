using System.Data.Entity;

namespace JailRoster
{
    public class JailRosterDataContext : DbContext
        {
        public JailRosterDataContext()
            : base( "SERVER=.;Integrated Security=True;Database=JailRoster" )
            {
            }
        public DbSet<Detainee>  Detainees { get; set; }
        }
}
