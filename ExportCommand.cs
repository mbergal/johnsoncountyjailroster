using System;
using System.IO;
using System.Linq;
using ManyConsole;

namespace JailRoster
    {
    class ExportCommand : ConsoleCommand
        {
        private string _outputFile;

        public ExportCommand()
            {
            IsCommand( "export" );
            HasRequiredOption("outputFile=", "output file.", s => { _outputFile = s; });

            }

        public override int Run(string[] remainingArguments)
            {
            using ( var dataContext  = new JailRosterDataContext()) 
                {
                var records = from d in dataContext.Detainees
                                from o in d.Offenses
                                    select new ExcelExportRecord 
                                        {
                                        ReportDate = d.ReportDate,
                                        DetaineeName = d.Name,
                                        Age = d.Age,
                                        DateBooked = d.DateBooked,
                                        HousingFacility = d.HousingFacility,
                                        JailRosterId = d.JailRosterId,
                                        OffenseLevel = o.OffenseLevel,
                                        OffenseName = o.OffenseName,
                                        CauseNumber = o.CauseNumber,
                                        CodeSection = o.CodeSection,
                                        BondType = o.BondType,
                                        BondAmount = o.BondAmount,
                                        ChargeReleased = o.ChargeReleased
                                        };

                using ( var textWriter = new StreamWriter( _outputFile ) )
                using ( var csvWriter = new CsvHelper.CsvWriter( textWriter ) )
                    csvWriter.WriteRecords( records );
                }
            return 0;
            }
        }

    internal class ExcelExportRecord 
        {
        public DateTime ReportDate { get; set; }
        public int      JailRosterId { get; set; }
        public string   DetaineeName { get; set; }
        public int      Age { get; set; }
        public DateTime DateBooked { get; set; }
        public string   HousingFacility { get; set; }
        public string   OffenseLevel { get; set; }
        public string   OffenseName { get; set; }
        public string   CauseNumber { get; set; }
        public string   CodeSection { get; set; }
        public string   BondType { get; set; }
        public string   BondAmount { get; set; }
        public string   ChargeReleased { get; set; }
        }
    }