package model.collectibles;

import exceptions.NoAvailableResourcesException;
import exceptions.NotEnoughActionsException;
import model.characters.Hero;

public interface Collectible {
	
	public void pickUp (Hero h);
	
	public void use(Hero h) throws NoAvailableResourcesException, NotEnoughActionsException;

}
// added the 2 new methods here first but left them blank