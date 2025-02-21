// See https://aka.ms/new-console-template for more information
class Program {
    static void Main() {
        List<List<string>> testCases = new List<List<string>> {
            new List<string> { 
                "OR R1, R2, R2"  //no dep
             }, 

            new List<string> { 
                "ADD R1, R2, R3", //R1 RAW
                "SUB R4, R1, R5" 
            }, 

            new List<string> { 
                "ADDI R1, R2, 0",   //R1 and R3 RAW
                "ADD R3, R1, R4", 
                "SUB R5, R3, R6" 
            }, 

            new List<string> { 
                "ADDI R1, R2, 0", 
                "ADD R3, R1, R4",  //R1, R3 and R5
                "SUB R5, R3, R6", 
                "AND R7, R5, R8" 
            },

            new List<string> { 
                "ADD R1, R2, R3", 
                "SUB R4, R1, R5",  //R1, R4, R6
                "AND R6, R4, R7", 
                "OR R8, R6, R9" 
            },

            new List<string> { 
                "ADD R1, R2, R3", 
                "OR R4, R5, R6", 
                "SUB R7, R1, R4", 
                "AND R8, R7, R9" 
            },

            new List<string> { 
                "OR R1, R2, R2", 
                "OR R3, R4, R4", 
                "ADD R5, R1, R3", 
                "SUB R6, R5, R7", 
                "AND R8, R6, R9" 
            }, 

            new List<string> { 
                "ADD R1, R2, R3", 
                "ADD R2, R3, R4", 
                "ADD R3, R4, R5", 
                "AND R8, R1, R2", 
                "OR R9, R3, R8" 
            }, 

            new List<string> { 
                "ADDI R2, R1, 0", 
                "ADDI R3, R2, 0", 
                "ADDI R4, R3, 0", 
                "ADDI R5, R4, 0", 
                "ADDI R6, R5, 0" 
            }, 

            new List<string> { 
                "OR R3, R1, R1", 
                "OR R1, R2, R2" 
            },

            new List<string> { 
                "ADD R1, R2, R3", 
                "SUB R2, R4, R5", 
                "AND R3, R6, R7", 
                "OR R8, R1, R9", 
                "XOR R9, R2, R10" 
            },

            new List<string> { 
                "ADD R1, R2, R3", 
                "ADD R2, R3, R4", 
                "ADD R3, R4, R5", 
                "ADD R4, R5, R6", 
                "ADD R5, R6, R7", 
                "AND R6, R7, R8" 
            }, 

            new List<string> { 
                "ADDI R1, R2, 0", 
                "ADD R3, R1, R4", 
                "SUB R5, R3, R6", 
                "AND R7, R5, R8", 
                "OR R9, R7, R10", 
                "XOR R11, R9, R12" 
            }, 

            new List<string> { 
                "ADDI R1, R2, 0", 
                "ADD R3, R1, R4", 
                "SUB R5, R3, R6", 
                "ADD R7, R5, R8", 
                "ADD R9, R7, R10", 
                "XOR R11, R9, R12", 
                "OR R13, R11, R14" 
            }
        };

        for (int i = 0; i < testCases.Count; i++) {
            Console.WriteLine($"=== Test Case {i + 1} ===");
            InstructionsScheduler scheduler = new InstructionsScheduler(testCases[i]);
            scheduler.Run();
            Console.WriteLine();
        }
    }
}

