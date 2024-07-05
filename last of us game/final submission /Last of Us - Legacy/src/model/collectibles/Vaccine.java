package model.collectibles;

import java.awt.Point;
import java.util.ArrayList;

import engine.Game;
import exceptions.NoAvailableResourcesException;
import exceptions.NotEnoughActionsException;
import model.characters.Hero;
import model.world.CharacterCell;

public class Vaccine implements Collectible {

	public Vaccine() {
		
	}
	
	public void pickUp (Hero h) {
		
		h.addVaccine(this);
		
	}
	
	public void use(Hero h) throws NoAvailableResourcesException, NotEnoughActionsException {
		if(h.getActionsAvailable()<=0)
			throw new NotEnoughActionsException();
		
		h.setActionsAvailable(h.getActionsAvailable()-1);
		
		
		h.getVaccineInventory().remove(this);
		
		Game.zombies.remove(h.getTarget());
		
		Hero h1 =Game.availableHeroes.remove(0);
		Game.heroes.add(h1);
		
		
		
		Point zombieLocation=h.getTarget().getLocation();
		int x=zombieLocation.x;
		int y=zombieLocation.y;
		Game.map[x][y]=new CharacterCell(h1);
		h1.setLocation(new Point(x,y));
	}

}
