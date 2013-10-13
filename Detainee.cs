using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JailRoster
    {
    public class Detainee 
        {
        [Key,DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        public int JailRosterId { get; set; }
        public int Age { get; set; }
        public DateTime DateBooked { get; set; }
        public string HousingFacility { get; set; }
        public virtual ICollection<Offense> Offenses { get; set; }
        public string Name { get; set; }
        }
    }