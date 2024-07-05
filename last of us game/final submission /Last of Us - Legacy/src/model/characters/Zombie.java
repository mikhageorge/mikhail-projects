package model.characters;

import java.awt.Point;
import java.util.ArrayList;

import model.world.CharacterCell;
import engine.Game;
import exceptions.InvalidTargetException;
import exceptions.NotEnoughActionsException;



public class Zombie extends Character {
	static int ZOMBIES_COUNT = 1;
	
	public static int getZOMBIES_COUNT() {
		return ZOMBIES_COUNT;
	}


	public static void setZOMBIES_COUNT(int zOMBIES_COUNT) {
		ZOMBIES_COUNT = zOMBIES_COUNT;
	}


	public Zombie() {
		super("Zombie " + ZOMBIES_COUNT, 40, 10);
		ZOMBIES_COUNT++;
		
	}
	
	
	
	
	public void attack() throws InvalidTargetException, NotEnoughActionsException{
		 
		Point p=this.getLocation();
		ArrayList<Point> pList=Game.adjacentPoints(p);
		
		boolean found=false;
		while(!pList.isEmpty()){
			Point p1=pList.remove(0);
			if(Game.map[p1.x][p1.y] instanceof CharacterCell){
				CharacterCell cc=(CharacterCell)(Game.map[p1.x][p1.y]);
				if(cc.getCharacter() instanceof Hero){
						this.setTarget(cc.getCharacter());
						found=true;
						break;	
				}
			}
		}
		if(found)
			super.attack();
		
	
	}
	
	

}


