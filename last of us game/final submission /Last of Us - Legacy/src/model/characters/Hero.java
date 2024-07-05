package model.characters;

import java.util.ArrayList;
import java.awt.Point;

import engine.Game;
import exceptions.GameActionException;
import exceptions.InvalidTargetException;
import exceptions.MovementException;
import exceptions.NoAvailableResourcesException;
import exceptions.NotEnoughActionsException;
import model.collectibles.Supply;
import model.collectibles.Vaccine;
import model.world.CharacterCell;
import model.world.CollectibleCell;
import model.world.TrapCell;


public abstract class Hero extends Character {
	

		private int actionsAvailable;
		private int maxActions;
		private ArrayList<Vaccine> vaccineInventory;
		private ArrayList<Supply> supplyInventory;
		private boolean specialAction;
		
	
		
		public Hero(String name,int maxHp, int attackDmg, int maxActions) {
			super(name,maxHp, attackDmg);
			this.maxActions = maxActions;
			this.actionsAvailable = maxActions;
			this.vaccineInventory = new ArrayList<Vaccine>();
			this.supplyInventory=new ArrayList<Supply>();
			this.specialAction=false;
		
		}
		
		
	


		public boolean isSpecialAction() {
			return specialAction;
		}



		public void setSpecialAction(boolean specialAction) {
			this.specialAction = specialAction;
		}



		public int getActionsAvailable() {
			return actionsAvailable;
		}



		public void setActionsAvailable(int actionsAvailable) {
			this.actionsAvailable = actionsAvailable;
		}



		public int getMaxActions() {
			return maxActions;
		}



		public ArrayList<Vaccine> getVaccineInventory() {
			return vaccineInventory;
		}


		public ArrayList<Supply> getSupplyInventory() {
			return supplyInventory;
		}
		
		public void addVaccine(Vaccine v) {
			
			vaccineInventory.add(v);
		}
		
		public void addSupply(Supply s) {
			supplyInventory.add(s);
		}
		
		public void removeVac(Vaccine v)throws NoAvailableResourcesException{
			if(vaccineInventory.contains(v)){
				vaccineInventory.remove(v);
			}
			else{
				throw new NoAvailableResourcesException();
			}
		}
		
		public void removeSup(Supply s) throws NoAvailableResourcesException{
			if(supplyInventory.contains(s)){
				supplyInventory.remove(s);
			}
			else{
				throw new NoAvailableResourcesException();
			}
			
			
		}
		
		
		
		
		
		
		//newly added to check if a hero used all vaccines or not to see if the player wins or not
		public boolean allVaccinesUsed() {
			
			if(vaccineInventory.size()==0)
				return true;
	
			return false;
			
		}
		
		public void attack() throws InvalidTargetException, NotEnoughActionsException{
			if(this.getTarget() instanceof Hero)
				throw new InvalidTargetException(); 
			
			if(this instanceof Fighter && specialAction==true){
				super.attack();
				return;
			}
			
			if(this.actionsAvailable==0)
				throw new NotEnoughActionsException();
			super.attack();
			this.actionsAvailable-=1;
			
		}
		
		public void move(Direction d) throws MovementException, NotEnoughActionsException{

			if(this.actionsAvailable==0)
				throw new NotEnoughActionsException();
			
			
			if(this.getCurrentHp()<=0){
				//this.onCharacterDeath();
				((CharacterCell) Game.map[this.getLocation().x][this.getLocation().y]).setCharacter(null);
				return;
			}
				
			int v=this.getLocation().x;
			int h=this.getLocation().y;
			Point p;
			switch(d){
			case UP:
				if(v==14){
					throw new MovementException("Can not move up");
				}
				p=new Point(v+1,h);
				break;
			case DOWN:
				if(v==0){
					throw new MovementException("Can not move down");
				}
				p=new Point(v-1,h);
				break;
			case RIGHT:
				if(h==14){
					throw new MovementException("Can not move right");
				}
				p=new Point(v,h+1);
				break;
			 default:
				 if(h==0){
					throw new MovementException("Can not move left");
				 }
				p=new Point(v,h-1);
			}
			if(Game.map[p.x][p.y].isOccupied()) {
				throw new MovementException("already occupied cell");
			}
			actionsAvailable-=1;
			this.setLocation(p);
			if(Game.map[p.x][p.y] instanceof TrapCell) {
				
				TrapCell tc=(TrapCell)(Game.map[p.x][p.y]);
				this.setCurrentHp(getCurrentHp()-tc.getTrapDamage());
				if (this.getCurrentHp()<=0){
					this.onCharacterDeath();
					Game.map[p.x][p.y]=new CharacterCell(null);	
				}
				else{
					Game.map[p.x][p.y]=new CharacterCell(this);
				}
			}
			
			else if(Game.map[p.x][p.y] instanceof CollectibleCell) {
				CollectibleCell cc=(CollectibleCell)(Game.map[p.x][p.y]);
				cc.getCollectible().pickUp(this);
				Game.map[p.x][p.y]=new CharacterCell(this);	
			}
			else{
				CharacterCell cc=(CharacterCell)(Game.map[p.x][p.y]);
				Game.map[p.x][p.y]=new CharacterCell(this,cc.isSafe());
			}
			
			ArrayList<Point> adjacentList=Game.adjacentPoints(p);
			
			CharacterCell cc2=(CharacterCell)(Game.map[v][h]);
			Game.map[v][h]= new CharacterCell(null,cc2.isSafe());
			while(!adjacentList.isEmpty()){
				Point p1= adjacentList.remove(adjacentList.size()-1);
				int x1=p1.x;
				int y1=p1.y;
				Game.map[x1][y1].setVisible(true);
			}
			
		}
		
		
		public void useSpecial() throws NotEnoughActionsException,NoAvailableResourcesException, InvalidTargetException{

			if(this.getSupplyInventory().size()==0){
				throw new NoAvailableResourcesException("no available supplies");
			}
			if(this.actionsAvailable==0)
				throw new NotEnoughActionsException();
			if(this.specialAction){
				throw new NotEnoughActionsException("you already used this hero's special action");
			}
			specialAction=true;	
			int supInventorySize=this.getSupplyInventory().size();
			this.getSupplyInventory().remove(supInventorySize-1);
			this.setActionsAvailable(this.getActionsAvailable()-1);
			
		}
		//3ayza ageeb el vaccine adeeh lel zombie fa hastakhdem use method? 
		//3ayza en el zombie yekon f adjacent cell belnesba lel hero fa lazm a3ml method lel hwar da
		public void cure() throws InvalidTargetException,NoAvailableResourcesException, NotEnoughActionsException{
			
			

			if(this.getTarget()==null)
				throw new InvalidTargetException();
			
			if(this.getActionsAvailable()==0)
				throw new NotEnoughActionsException();
			
			
			if(this.getTarget() instanceof Hero){
				throw new InvalidTargetException();
			}
			
			if(this.vaccineInventory.isEmpty()){
				
				throw new NoAvailableResourcesException();
			}
			Point zombieLocation=this.getTarget().getLocation();
			if(!Character.isAdjacent(zombieLocation,this.getLocation())){
				throw new InvalidTargetException();
			}
			
			this.getVaccineInventory().get(0).use(this);
			//Game.map[zombieLocation.x][zombieLocation.y]=new CharacterCell()

		}
		
		public void heal() {
			this.setCurrentHp(this.getMaxHp());
		}
		
		
		
		





















}
