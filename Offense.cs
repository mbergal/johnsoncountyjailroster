using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JailRoster
    {
    public class Offense 
        {
        [Key,DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int    Id { get; set; }

        public int    DetaineeId { get; set; }
        public string OffenseName { get; set; }
        public string CodeSection { get; set; }
        public string OffenseLevel { get; set; }
        public string CauseNumber { get; set; }
        public string BondType { get; set; }
        public string BondAmount { get; set; }
        public string ChargeReleased { get; set; }
        }
    }