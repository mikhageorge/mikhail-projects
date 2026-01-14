package battle;

import java.util.*;

import battle.Node;
import battle.Node.player;

public class BattleSolver {

    // enum player {
    // A, B
    // }
    public player startingPlayer;
    public int expandednodessofar;
    public Node initialNode; // this attribute MUST be used to store the initial node in the search tree

    private void parseStats(String statsStr, ArrayList<Integer> health, ArrayList<Integer> damage) {
        String[] tokens = statsStr.split(",");

        for (int i = 0; i < tokens.length; i += 2) {
            health.add(Integer.parseInt(tokens[i]));
            damage.add(Integer.parseInt(tokens[i + 1]));
        }
    }

    private Node initialStringToNode(String str) {

        String[] parts = str.split(";", 3);
        String partA = parts[0];
        String partB = parts[1];

        // I faced an error here when i tried to use the same approach as before with
        // arrays so I had to make it this way to work
        ArrayList<Integer> healthA = new ArrayList<>();
        ArrayList<Integer> damageA = new ArrayList<>();
        parseStats(partA, healthA, damageA);

        ArrayList<Integer> healthB = new ArrayList<>();
        ArrayList<Integer> damageB = new ArrayList<>();
        parseStats(partB, healthB, damageB);

        char startPlayerChar = parts[2].charAt(0);
        this.startingPlayer = (startPlayerChar == 'A') ? player.A : player.B;

        Node n = new Node(healthA, damageA, healthB, damageB, null, this.startingPlayer, null,
                Integer.MIN_VALUE, Integer.MAX_VALUE);

        return n;

    }

    // this is the solution to return a pair of results because in the pseudocode of
    // the algorithm in the lecture , 2 values are returned
    private class resultpair {
        int score; // This is 'v' (utility)
        ArrayList<String> plan;

        resultpair(int score, ArrayList<String> plan) {
            this.score = score;
            this.plan = plan;
        }
    }

    public ArrayList<String> actions(Node state) {
        ArrayList<String> availableActions = new ArrayList<>();

        if (state.currentPlayer == player.A) {
            // Loop through all A's units
            for (int attackerPos = 0; attackerPos < state.healthA.size(); attackerPos++) {
                // Check if the attacker is alive
                if (state.healthA.get(attackerPos) > 0) {
                    // Loop through all B's units
                    for (int targetPos = 0; targetPos < state.healthB.size(); targetPos++) {
                        // Check if the target is alive
                        if (state.healthB.get(targetPos) > 0) {
                            availableActions.add("A(" + attackerPos + "," + targetPos + ")");
                        }
                    }
                }
            }
        } else {
            for (int attackerPos = 0; attackerPos < state.healthB.size(); attackerPos++) {
                if (state.healthB.get(attackerPos) > 0) {

                    for (int targetPos = 0; targetPos < state.healthA.size(); targetPos++) {
                        if (state.healthA.get(targetPos) > 0) {
                            availableActions.add("B(" + attackerPos + "," + targetPos + ")");
                        }
                    }
                }
            }
        }

        return availableActions;
    }

    public Node result(Node parentState, String action) {

        // Get the next player
        player nextPlayer = parentState.getNextPlayer(parentState.currentPlayer);

        // Create the new child node.
        Node childNode = new Node(parentState.healthA, parentState.damageA, parentState.healthB, parentState.damageB,
                parentState, nextPlayer, action, Integer.MIN_VALUE, Integer.MAX_VALUE);

        // Parse the action string
        String numbers = action.substring(2, action.length() - 1);
        String[] parts = numbers.split(",");
        int attackerPos = Integer.parseInt(parts[0]);
        int targetPos = Integer.parseInt(parts[1]);

        // Apply the damage

        if (parentState.currentPlayer == player.A) {
            // here A is attacking
            int damage = parentState.damageA.get(attackerPos);
            int targetOldHealth = parentState.healthB.get(targetPos);

            int newHealth = targetOldHealth - damage;
            if (newHealth < 0) {
                childNode.healthB.set(targetPos, 0);
            } else {
                childNode.healthB.set(targetPos, newHealth);
            }

        } else {
            // here B is attacking
            int damage = parentState.damageB.get(attackerPos);
            int targetOldHealth = parentState.healthA.get(targetPos);

            int newHealth = targetOldHealth - damage;
            if (newHealth < 0) {
                childNode.healthA.set(targetPos, 0);
            } else {
                childNode.healthA.set(targetPos, newHealth);
            }
        }

        return childNode;
    }

    public resultpair maxValue(Node state) {

        if (state.isTerminal()) {
            int utility = state.calculateUtility(this.startingPlayer);
            return new resultpair(utility, new ArrayList<>());
        }

        this.expandednodessofar++;

        int bestScore = Integer.MIN_VALUE;
        ArrayList<String> bestPlan = new ArrayList<>();

        for (String action : actions(state)) {
            Node child = result(state, action);
            resultpair result = minValue(child);

            if (result.score > bestScore) {
                bestScore = result.score;
                bestPlan = new ArrayList<>(result.plan);
                bestPlan.add(action);
            }
        }
        state.value = bestScore;
        return new resultpair(bestScore, bestPlan);
    }

    public resultpair minValue(Node state) {

        if (state.isTerminal()) {
            int utility = state.calculateUtility(this.startingPlayer);
            return new resultpair(utility, new ArrayList<>());
        }

        this.expandednodessofar++;

        int bestScore = Integer.MAX_VALUE;
        ArrayList<String> bestPlan = new ArrayList<>();

        for (String action : actions(state)) {
            Node child = result(state, action);
            resultpair result = maxValue(child);

            if (result.score < bestScore) {
                bestScore = result.score;
                bestPlan = new ArrayList<>(result.plan);
                bestPlan.add(action);
            }
        }

        state.value = bestScore;
        return new resultpair(bestScore, bestPlan);
    }

    public resultpair maxValue_AB(Node state, int alpha, int beta) {

        if (state.isTerminal()) {
            int utility = state.calculateUtility(this.startingPlayer);
            return new resultpair(utility, new ArrayList<>());
        }

        this.expandednodessofar++;

        int bestScore = Integer.MIN_VALUE;

        ArrayList<String> bestPlan = new ArrayList<>();

        for (String action : actions(state)) {
            Node child = result(state, action);
            resultpair result = minValue_AB(child, alpha, beta);

            if (result.score > bestScore) {
                bestScore = result.score;
                bestPlan = new ArrayList<>(result.plan);
                bestPlan.add(action);
                alpha = Integer.max(alpha, bestScore);
                state.alpha = alpha;
            }

            if (bestScore >= beta) {
                return new resultpair(bestScore, bestPlan);
            }
        }

        state.value = bestScore;
        return new resultpair(bestScore, bestPlan);
    }

    public resultpair minValue_AB(Node state, int alpha, int beta) {

        if (state.isTerminal()) {
            int utility = state.calculateUtility(this.startingPlayer);
            return new resultpair(utility, new ArrayList<>());
        }

        this.expandednodessofar++;

        int bestScore = Integer.MAX_VALUE;
        ArrayList<String> bestPlan = new ArrayList<>();

        for (String action : actions(state)) {
            Node child = result(state, action);
            resultpair result = maxValue_AB(child, alpha, beta);

            if (result.score < bestScore) {
                bestScore = result.score;
                bestPlan = new ArrayList<>(result.plan);
                bestPlan.add(action);
                beta = Integer.min(beta, bestScore);
                state.beta = beta;
            }

            if (bestScore <= alpha) {
                return new resultpair(bestScore, bestPlan);
            }
        }

        state.value = bestScore;
        return new resultpair(bestScore, bestPlan);
    }

    public String solve_MINMAX(String initialString) {
        this.expandednodessofar = 0;
        initialNode = initialStringToNode(initialString);
        resultpair result = maxValue(this.initialNode);
        String planString = "";

        if (result.plan != null && !result.plan.isEmpty()) {
            Collections.reverse(result.plan);
            planString = String.join(",", result.plan);
        }
        return planString + ";" + result.score + ";" + this.expandednodessofar + ";";
    }

    public String solve_With_Pruning(String initialString) {
        this.expandednodessofar = 0;
        initialNode = initialStringToNode(initialString);
        resultpair result = maxValue_AB(this.initialNode, Integer.MIN_VALUE, Integer.MAX_VALUE);
        String planString = "";

        if (result.plan != null && !result.plan.isEmpty()) {
            Collections.reverse(result.plan);
            planString = String.join(",", result.plan); // Joins the list with commas
        }
        // returns "plan;score;expandednodessofar;"
        return planString + ";" + result.score + ";" + this.expandednodessofar + ";";

    }

    public String solve(String initialStateString, boolean ab, boolean visualize) {
        this.expandednodessofar = 0;
        initialNode = initialStringToNode(initialStateString);

        if (!ab) {
            return solve_MINMAX(initialStateString);
        } else {

            return solve_With_Pruning(initialStateString);
        }

    }

}
