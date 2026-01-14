package battle;

import java.util.ArrayList;
import java.util.List;

//import battle.BattleSolver.player;

public class Node {

    // you can add a state representation attribute or any other attributes you need

    public ArrayList<Integer> healthA;
    public ArrayList<Integer> damageA;
    public ArrayList<Integer> healthB;
    public ArrayList<Integer> damageB;

    public enum player {
        A, B
    }

    public player currentPlayer;

    public int value; // MinMax value of the node
    public Node parent;

    public String actionBeforeThisNode;
    public int alpha;
    public int beta;

    public Node(ArrayList<Integer> healthA, ArrayList<Integer> damageA,
            ArrayList<Integer> healthB, ArrayList<Integer> damageB,
            Node parent, player currentPlayer, String actionBeforeThisNode, int alpha, int beta) {

        this.healthA = new ArrayList<>(healthA);
        this.damageA = new ArrayList<>(damageA);
        this.healthB = new ArrayList<>(healthB);
        this.damageB = new ArrayList<>(damageB);

        this.parent = parent;
        this.currentPlayer = currentPlayer;
        this.actionBeforeThisNode = actionBeforeThisNode;
        this.value = 0;

        this.alpha = alpha;
        this.beta = beta;

    }

    public int getTotalHealthA() {

        int totalhealthA = 0;
        for (int health : healthA) {
            totalhealthA += health;
        }
        return totalhealthA;
    }

    public int getTotalHealthB() {

        int totalhealthB = 0;
        for (int health : healthB) {
            totalhealthB += health;
        }
        return totalhealthB;
    }

    // this checks if the game has ended
    public boolean isTerminal() {
        if (getTotalHealthA() == 0 || getTotalHealthB() == 0) {
            return true;
        }
        return false;
    }

    public int calculateUtility(player startingPlayer) {
        int totalHealthA = getTotalHealthA();
        int totalHealthB = getTotalHealthB();

        if (startingPlayer == player.A) {
            // this is the case where A starts
            if (totalHealthB == 0) {
                // here A won the game
                return totalHealthA;
            } else {
                // here A lost
                return -totalHealthB;
            }
        } else {
            // this is the case where B starts
            if (totalHealthA == 0) {
                // Here B won the game
                return totalHealthB;
            } else {
                // Here B lost
                return -totalHealthA;
            }
        }
    }

    public player getNextPlayer(player p) {
        if (p == player.A) {
            return player.B;
        } else {
            return player.A;
        }
    }

    public int getValue() {

        return this.value;
    }
}