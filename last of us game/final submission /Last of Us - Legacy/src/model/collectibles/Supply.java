package model.collectibles;

import exceptions.NoAvailableResourcesException;
import model.characters.Hero;

public class Supply implements Collectible  {

	

	
	public Supply() {
		
	}
	
	public void pickUp (Hero h) {
		
		h.addSupply(this);
	}
	
	public void use(Hero h) throws NoAvailableResourcesException {
		
		h.removeSup(this);
		
	}

/*added the 2 methods here and in vaccine but added body to both , there 
might be an exception that needs to be handeled here which 
is what happens if i use from an empty array*/ 
}
