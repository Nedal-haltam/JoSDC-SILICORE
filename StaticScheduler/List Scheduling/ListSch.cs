using System;
using System.Collections.Generic;
using System.Linq;

class InstructionsScheduler {
    private List<string> instructions;
    private Dictionary<int, List<int>> graph;
    private Dictionary<int, int> indegree;
    private Dictionary<int, int> priority;
    private Dictionary<string, int> regLastWritten;

    public InstructionsScheduler(List<string> instructions) {
        this.instructions = instructions;
        graph = new Dictionary<int, List<int>>();
        indegree = new Dictionary<int, int>();
        priority = new Dictionary<int, int>();
        regLastWritten = new Dictionary<string, int>();
    }

    private (int, string, string, List<string>) ParseInstructions(int idx, string instr) {
        var parts = instr.Replace(",", "").Split(' ');
        string op = parts[0];
        string dest = parts.Length > 1 ? parts[1] : null;
        List<string> sources = parts.Length > 2 ? parts.Skip(2).ToList() : new List<string>();
        return (idx, op, dest, sources);
    }

    private void BuildDependencyGraph() {
        for (int idx = 0; idx < instructions.Count; idx++) {
            var (instrIdx, op, dest, sources) = ParseInstructions(idx, instructions[idx]);

            foreach (var src in sources) {
                if (regLastWritten.ContainsKey(src)) {
                    if (!graph.ContainsKey(regLastWritten[src]))
                        graph[regLastWritten[src]] = new List<int>();

                    graph[regLastWritten[src]].Add(instrIdx);
                    indegree[instrIdx] = indegree.GetValueOrDefault(instrIdx, 0) + 1;
                }
            }

            if (dest != null) {
                regLastWritten[dest] = instrIdx;
            }
        }

        for (int i = 0; i < instructions.Count; i++) {
            if (!indegree.ContainsKey(i))
                indegree[i] = 0;
        }
    }

    private void ComputePriorities() {
        Dictionary<int, int> heights = new Dictionary<int, int>();

        int DFS(int node) {
            if (heights.ContainsKey(node)) return heights[node];
            if (!graph.ContainsKey(node) || graph[node].Count == 0) return heights[node] = 1;
            heights[node] = 1 + graph[node].ConvertAll(neigh => DFS(neigh)).Max();
            return heights[node];
        }

        for (int i = 0; i < instructions.Count; i++) {
            DFS(i);
        }
        priority = heights;
    }

    public void DisplayGraph() {
        Console.WriteLine("Dependency Graph (Adjacency List):");
        foreach (var kvp in graph) {
            Console.WriteLine($"Instruction {kvp.Key}: {string.Join(", ", kvp.Value)}");
        }

        Console.WriteLine("\nInstruction Priorities:");
        foreach (var kvp in priority.OrderByDescending(x => x.Value)) {
            Console.WriteLine($"Instruction {kvp.Key}: Priority {kvp.Value}");
        }
    }

    public void Run() {
        BuildDependencyGraph();
        ComputePriorities();
        DisplayGraph();
    }
}

