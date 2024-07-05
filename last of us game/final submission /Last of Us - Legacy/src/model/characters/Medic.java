package model.characters;

import java.util.ArrayList;
import java.awt.Point;
import engine.Game;
import exceptions.InvalidTargetException;
import exceptions.NoAvailableResourcesException;
import exceptions.NotEnoughActionsException;
import model.world.CharacterCell;



public class Medic extends Hero {
	//Heal amount  attribute - quiz idea
	

	public Medic(String name,int maxHp, int attackDmg, int maxActions) {
		super( name, maxHp,  attackDmg,  maxActions) ;
		
		
	}
	
	public void useSpecial() throws NotEnoughActionsException, NoAvailableResourcesException, InvalidTargetException{
		if(this.getTarget() instanceof Zombie)
			throw new InvalidTargetException();
		if(this.getTarget()==null)
			throw new InvalidTargetException();
		
		if(!isAdjacent(this.getTarget().getLocation(),this.getLocation()))
			throw new InvalidTargetException();
		
		super.useSpecial();
		this.setSpecialAction(false);
		((Hero)(getTarget())).heal();
		
	}
}
