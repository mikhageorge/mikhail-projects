package engine;
import java.lang.Math;
import java.awt.Point;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

import model.characters.Explorer;
import model.characters.Fighter;
import model.characters.Hero;
import model.characters.Medic;
import model.characters.Zombie;
import model.collectibles.Supply;
import model.collectibles.Vaccine;
import model.world.Cell;
import model.world.CharacterCell;
import model.world.CollectibleCell;
import model.world.TrapCell;
import model.world.CharacterCell;
import exceptions.InvalidTargetException;
import exceptions.NotEnoughActionsException;
import engine.Game;


//if Fighter.useSpecial() remove the option to stop attacking
//need to handle that empty cells with a null character
public class Game {
	
	public static Cell [][] map = new Cell[15][15];

	public static ArrayList <Hero> availableHeroes = new ArrayList<Hero>();
	public static ArrayList <Hero> heroes =  new ArrayList<Hero>();
	public static ArrayList <Zombie> zombies =  new ArrayList<Zombie>();
	//private static int vaccinesCollected=0;
	
	
	
		
	public static void loadHeroes(String filePath)  throws IOException {
		
		
		BufferedReader br = new BufferedReader(new FileReader(filePath));
		String line = br.readLine();
		while (line != null) {
			String[] content = line.split(",");
			Hero hero=null;
			switch (content[1]) {
			case "FIGH":
				hero = new Fighter(content[0], Integer.parseInt(content[2]), Integer.parseInt(content[4]), Integer.parseInt(content[3]));
				break;
			case "MED":  
				hero = new Medic(content[0], Integer.parseInt(content[2]), Integer.parseInt(content[4]), Integer.parseInt(content[3])) ;
				break;
			case "EXP":  
				hero = new Explorer(content[0], Integer.parseInt(content[2]), Integer.parseInt(content[4]), Integer.parseInt(content[3]));
				break;
			}
			availableHeroes.add(hero);
			line = br.readLine();
			
			
		}
		br.close();

	}
	
	//btebda2 elgame
	public static void startGame(Hero h) {
		
		heroes.add(h);
		availableHeroes.remove(h);

		for(int i=0;i<=14;i++) {
			for(int j=0;j<=14;j++) {
				map[i][j]=new CharacterCell();
			}
		}
		map[0][0]=new CharacterCell(h); // spawns a hero in the first place indicated in the requirements
		h.setLocation(new Point(0,0));
		
		//checks if a cell is empty first then puts a vaccine in it 
		for(int i=0;i<5;i++) {
			
			int rand1=(int)(Math.random()*15);
			int rand2=(int)(Math.random()*15);
			
			if(map[rand1][rand2].isEmpty()) {
				Vaccine v=new Vaccine();
				map[rand1][rand2]=new CollectibleCell(v);
			}
			else {
				i--;
			}
			
		}
		
		//spawn 5 supplies randomly on the map 
		for(int i=0;i<5;i++) {
			
			int rand1=(int)(Math.random()*15);
			int rand2=(int)(Math.random()*15);
			
			if(map[rand1][rand2].isEmpty()) {
				Supply s=new Supply();
				map[rand1][rand2]=new CollectibleCell(s);
			}
			else {
				i--;
			}
			
		}
		
		//spawn 5 traps randomly on the map 
		for(int i=0;i<5;i++) {
			
			int rand1=(int)(Math.random()*15);
			int rand2=(int)(Math.random()*15);
			
			if(map[rand1][rand2].isEmpty()) {
				map[rand1][rand2]=new TrapCell();
			}
			else {
				i--;
			}
			
		}
		//spawn 10 zombies randomly on the map 
		for(int i=0;i<10;i++) {
			
			int rand1=(int)(Math.random()*15);
			int rand2=(int)(Math.random()*15);
			
			if(map[rand1][rand2].isEmpty()) {
				
				Zombie z=new Zombie();
				map[rand1][rand2]=new CharacterCell(z,true);
				z.setLocation(new Point(rand1,rand2));
				zombies.add(z);
			}
		
			else {
				i--;
			}
			
		}
		
		
		ArrayList<Point> adjacentList= adjacentPoints(new Point(0,0));
		while(!adjacentList.isEmpty()){
			Point p3=adjacentList.remove(adjacentList.size()-1);
			map[p3.x][p3.y].setVisible(true);
		}
		
	}
	
	
	/*public static int getVaccinesCollected() {
		return vaccinesCollected;
	}

	public static void setVaccinesCollected(int vaccinesCollected) {
		Game.vaccinesCollected = vaccinesCollected;
	}*/

	public static boolean checkWin() {
		
		//if there is less than 5 hereos you dont win 
		if(heroes.size()<5)
			return false;
		
		for(int i=0;i<15;i++) {
			for(int j=0;j<15;j++) {
				
				if(map[i][j] instanceof CollectibleCell) {
					
					CollectibleCell cc=(CollectibleCell)(map[i][j]);
					if(cc.getCollectible() instanceof Vaccine) {
						return false;
					
					}
					
				}
				
			}
			
		}
		
		//checks if hero used all vaccines available to him so added method allvaccineused in hero class
		for(int i=0;i<heroes.size();i++) {
			Hero h=heroes.get(i);
			
			if(!h.allVaccinesUsed())
				return false;
		}
		
		return true;
		
		
	}
	
	
	public static boolean checkGameOver() {
		
		if (checkWin()|| heroes.size()==0){
			return true;
		}
		
		for(int i=0;i<15;i++) {
			for(int j=0;j<15;j++) {
				
				if(map[i][j] instanceof CollectibleCell) {
					
					CollectibleCell cc=(CollectibleCell)(map[i][j]);
					if(cc.getCollectible() instanceof Vaccine) {
						return false;
					}
				}
			}
		}
		
		
		for(int i=0;i<heroes.size();i++) {
			Hero h=heroes.get(i);
			
			if(!h.allVaccinesUsed())
				return false;
		}
		
		
		return true;
		
	
	}	
	
	public static ArrayList<Point> adjacentPoints(Point p){
		ArrayList<Point> adjacentList=new ArrayList<Point>();
		int v=p.x;
		int h=p.y;
		
		if(h-1>=0){
			adjacentList.add(new Point(v,h-1));
		}
		
		if(v-1>=0&&h-1>=0){
			adjacentList.add(new Point(v-1,h-1));
		}
		if(v+1<=14){
			adjacentList.add(new Point(v+1,h));
		}
		if(v-1>=0){
			adjacentList.add(new Point(v-1,h));
		}
		if(v+1<=14&&h+1<=14){
			adjacentList.add(new Point(v+1,h+1));
		}
		if(v+1<=14&&h-1>=0){
			adjacentList.add(new Point(v+1,h-1));
		}
		if(h+1<=14){
			adjacentList.add(new Point(v,h+1));
		}
		if(v-1>=0&&h+1<=14){
			adjacentList.add(new Point(v-1,h+1));
		}

		
		

		adjacentList.add(p);
		return adjacentList;
		
	}
	public static void endTurn() throws InvalidTargetException, NotEnoughActionsException{
		
		//each zombie attacks a hero
		//and sets target of each zombie b null 
		int zombiesSize=zombies.size();
		for(int i=zombiesSize-1;i>=0;i--){
			zombies.get(i).attack();
			zombies.get(i).setTarget(null);
		}
		
		
		//reset each heroes actions
		
		int heroesSize=Game.heroes.size();
		
		for(int i=heroesSize-1;i>=0;i--) {
			Hero h=Game.heroes.get(i);
			h.setActionsAvailable(h.getMaxActions());
			h.setSpecialAction(false);
			h.setTarget(null);
			
		}
		
	
		
		//spawn a zombie 
		boolean f=true;
		while(f) {
			int rand1=(int)(Math.random()*15);
			int rand2=(int)(Math.random()*15);
	
			if(map[rand1][rand2].isEmpty()) {
				Zombie z=new Zombie();
				map[rand1][rand2]=new CharacterCell(z);
				z.setLocation(new Point(rand1,rand2));
				zombies.add(z);
				f=false;						
			}
			
		}
		
	
		
	//only the cells adjacent to heroes should be visible
		
		for(int i=0;i<=14;i++) {
			for(int j=0;j<=14;j++) {
				map[i][j].setVisible(false);
			}
		}
		
		for(int i=0;i<=14;i++) {
			for(int j=0;j<=14;j++) {
				if(map[i][j] instanceof CharacterCell) {
					CharacterCell cc2=(CharacterCell)(map[i][j]);
	
					if(cc2.getCharacter() instanceof Hero) {
						map[i][j].setVisible(true);
						Point p1=new Point(i,j);
						ArrayList<Point> pList=adjacentPoints(p1);
						while(!pList.isEmpty()) {
							Point p2=pList.remove(pList.size()-1);
							map[p2.x][p2.y].setVisible(true);
						}
					}
					
				}
			}
		}
		
		
	}
	

	
	
	
	
	
}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	




