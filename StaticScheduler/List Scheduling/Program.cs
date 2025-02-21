// See https://aka.ms/new-console-template for more information
class Program{
    static void Main() {
        List<string> instructions = new List<string> {
            "ADD R1, R2, R3",
            "MUL R4, R1, R5",
            "SUB R6, R4, R7",
            "AND R8, R6, R9"
        };

        InstructionsScheduler scheduler = new InstructionsScheduler(instructions);
        scheduler.Run();
    }
}
