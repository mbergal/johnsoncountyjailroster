using System;
using System.Linq;
using System.Net;
using HtmlAgilityPack;

namespace JailRoster
{
    class Program
        {
        static void Main(string[] args)
            {
            using ( var dataContext  = new JailRosterDataContext()) 
                {
                var index = ScrapeIndex();
                foreach ( var detailUrl in index )
                    try {
                        var detainee = ScrapeDetainee("https://ww1.johnson-county.com/" + detailUrl );
                        detainee.ReportDate = DateTime.Today;
                        dataContext.Detainees.Add( detainee );
                        }
                    catch ( Exception ex ) // Jail Roster MVC frontend is buggy
                        {
                        Console.WriteLine( ex.Message + ex.StackTrace );
                        }
                dataContext.SaveChanges();
                }
            }

        static private string[]   ScrapeIndex()
            {
            var index = new WebClient().DownloadString( "https://ww1.johnson-county.com/Sheriff/JailRoster/FullList/?filter=RosterType%3Aall%7CName%3A" );
            var doc = new HtmlAgilityPack.HtmlDocument();
            doc.LoadHtml( index );
            var trs = doc.DocumentNode.SelectNodes("//table[@class='data']/tr[string-length(@id) > 0]").ToArray();
            var details = trs.Select( x=> x.SelectSingleNode( "td/span[@id='details']/input").GetAttributeValue( "value", "" )).ToArray();
            return details.ToArray();
            }

        static private Detainee   ScrapeDetainee( string url )
            {
            var details = new WebClient().DownloadString( url );
            var doc = new HtmlAgilityPack.HtmlDocument();
            doc.LoadHtml( details );
            var detainee = new Detainee()
                {
                JailRosterId = int.Parse( doc.DocumentNode.SelectSingleNode( "//input[@id='jID']").GetAttributeValue( "value", "" ) ),
                Name = doc.DocumentNode.SelectSingleNode( "//input[@id='n']").GetAttributeValue( "value", "" ),
                Age = int.Parse( doc.DocumentNode.SelectSingleNode( ".//table[@class='data']/tr/td").InnerText ),
                DateBooked = DateTime.Parse( doc.DocumentNode.SelectSingleNode( ".//table[@class='data']/tr/td[2]").InnerText  ),
                HousingFacility = doc.DocumentNode.SelectSingleNode( ".//table[@class='data']/tr/td[3]").InnerText.Trim( "\n\r ".ToCharArray()),
                Offenses = ScrapeOffenses( doc )
                };
            

            return detainee;
            }

        private static Offense[] ScrapeOffenses(HtmlDocument doc)
            {
            var offenses = doc.DocumentNode.SelectNodes( "//div[@id='offense']" );
            return offenses != null 
                ? offenses.Select( ScrapeOffense ).ToArray() 
                : new Offense[] {};
            }

        private static Offense ScrapeOffense(HtmlNode htmlNode)
            {
            return new Offense()
                {
                OffenseName = htmlNode.SelectSingleNode( ".//table/tr[2]/td[1]").InnerText.TrimWhitespace(),
                CodeSection = htmlNode.SelectSingleNode( ".//table/tr[2]/td[2]").InnerText.TrimWhitespace(),
                OffenseLevel = htmlNode.SelectSingleNode( ".//table/tr[2]/td[3]").InnerText.TrimWhitespace(),
                CauseNumber =  htmlNode.SelectSingleNode( ".//table[2]/tr[2]/td[1]").InnerText.TrimWhitespace(),
                BondType = htmlNode.SelectSingleNode( ".//table[2]/tr[2]/td[2]").InnerText.TrimWhitespace(),
                BondAmount = htmlNode.SelectSingleNode( ".//table[2]/tr[2]/td[3]").InnerText.TrimWhitespace(),
                ChargeReleased = htmlNode.SelectSingleNode( ".//table[2]/tr[2]/td[4]").InnerText.TrimWhitespace(),

                };
            }
    }

public static class Extensions
        {
        public static string TrimWhitespace( this string str )
            {
            return str.Trim( "\n\r ".ToCharArray() );
            }
        }
}
