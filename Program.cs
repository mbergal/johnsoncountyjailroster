using System;
using ManyConsole;

namespace JailRoster
{
    class Program
        {
        static int Main(string[] args)
            {
            // then run them.
            return ConsoleCommandDispatcher.DispatchCommand(ConsoleCommandDispatcher.FindCommandsInSameAssemblyAs(typeof(Program)), args, Console.Out );
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
