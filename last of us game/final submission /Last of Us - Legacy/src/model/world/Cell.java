package model.world;



public abstract class Cell {
	
	
	private boolean isVisible;
	
	public Cell() {
		isVisible = false;	
	}
	
	public boolean isVisible() {
	
		return isVisible;
	
	}
	
	public void setVisible(boolean isVisible) {
	
		this.isVisible = isVisible;
	
	}
	//returns true only if a hero or zombie occupies the cell
	public boolean isOccupied(){
		if(this instanceof CharacterCell){
			CharacterCell cc=(CharacterCell)(this);
			if(cc.getCharacter()!=null){
				return true;
			}
		}
		return false;
			
	}
	//returns true only if totally empty cell
	public boolean isEmpty(){
		if(this instanceof CharacterCell){
			CharacterCell cc=(CharacterCell)(this);
			if(cc.getCharacter()==null){
				return true;
			}
		}
		return false;
	}
	

	
}


