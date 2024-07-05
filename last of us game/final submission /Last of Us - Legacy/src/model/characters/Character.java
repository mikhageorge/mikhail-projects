package model.characters;

import java.awt.Point;

import model.world.CharacterCell;
import exceptions.InvalidTargetException;
import exceptions.NotEnoughActionsException;
import engine.Game;


public abstract class Character {
	private String name;
	private Point location;
	private int maxHp;
	private int currentHp;
	private int attackDmg;
	private Character target;

	
	public Character() {
	}
	

	public Character(String name, int maxHp, int attackDmg) {
		this.name=name;
		this.maxHp = maxHp;
		this.currentHp = maxHp;
		this.attackDmg = attackDmg;
	}
		
	public Character getTarget() {
		return target;
	}

	public void setTarget(Character target) {
		this.target = target;
	}
	
	public String getName() {
		return name;
	}

	public Point getLocation() {
		return location;
	}

	public void setLocation(Point location) {
		this.location = location;
	}

	public int getMaxHp() {
		return maxHp;
	}

	public int getCurrentHp() {
		return currentHp;
	}

	public void setCurrentHp(int currentHp) {
		if(currentHp < 0) 
			this.currentHp = 0;
		else if(currentHp > maxHp) 
			this.currentHp = maxHp;
		else 
			this.currentHp = currentHp;
	}

	public int getAttackDmg() {
		return attackDmg;
	}
	
	
	
	
	public void attack() throws InvalidTargetException, NotEnoughActionsException{
		
		if(this.target==null)
			throw new InvalidTargetException("no specified target");
		
		if(!isAdjacent(location,target.location))
			throw new InvalidTargetException("the target is not in an adjacent position");
	
		this.target.setCurrentHp(this.target.getCurrentHp()-this.attackDmg);
		this.defend(this.target);
		
		if(target.currentHp<=0)
			target.onCharacterDeath();
		
		if(this.currentHp<=0)
			this.onCharacterDeath();
		
		
	}
	
	
	public void defend(Character c) throws InvalidTargetException, NotEnoughActionsException{
		
		
		//character c defend and this attacks
		int halfDamage=c.attackDmg/2;
		this.setCurrentHp(this.getCurrentHp()-halfDamage);
		if(this.currentHp<=0)
			this.onCharacterDeath();
	}
	
	

	public void onCharacterDeath(){
		int x=this.location.x;
		int y=this.location.y;
		CharacterCell cc=(CharacterCell)(Game.map[x][y]);
		Game.map[x][y]=new CharacterCell(null,cc.isSafe());
		if(this instanceof Zombie){
			Game.zombies.remove(this);
			for(int i=0;i<1;i++) {	
				int rand1=(int)(Math.random()*15);
				int rand2=(int)(Math.random()*15);					
				if(Game.map[rand1][rand2].isEmpty()&&Game.map[rand1][rand2] instanceof CharacterCell) {
					Zombie z=new Zombie();
					Game.map[rand1][rand2]=new CharacterCell(z,true);
					Game.zombies.add(z);
					z.setLocation(new Point(rand2,rand2));
				}
				else {
					i--;
				}
			}
		}
		
		if(this instanceof Hero){
			
			Game.heroes.remove((Hero)(this));
			Game.map[x][y].setVisible(true);
		}
		
	}
	
	public static int mod(int x){
		if(x>=0)
			return x;
		
		return -x;
		
	}
	
	public static boolean isAdjacent(Point p1 , Point p2 ){
		
		int x1=p1.x;
		int x2=p2.x;
		int y1=p1.y;
		int y2=p2.y;
		if(mod(x1-x2)<=1&&mod(y1-y2)<=1)
			return true;
		return false;
		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

}
