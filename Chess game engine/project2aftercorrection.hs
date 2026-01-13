-- check intersperse for new line
import Data.Char


type Location = (Char, Int)
data Player = White | Black deriving (Show, Eq)
data Piece = P Location | N Location | K Location | Q Location | R Location | B Location deriving (Show, Eq)
type Board = (Player, [Piece], [Piece])





setBoard :: Board
setBoard = (White, whitePieces, blackPieces)
  where
    whitePieces = [R ('h',1),N ('g',1),B ('f',1),K ('e',1),Q ('d',1),B ('c',1),N ('b',1),R ('a',1)] ++
                  [P (col,2) | col <- ['a'..'h']]
    blackPieces = [R ('h',8),N ('g',8),B ('f',8),K ('e',8),Q ('d',8),B ('c',8),N ('b',8),R ('a',8)] ++
                  [P (col,7) | col <- ['a'..'h']]

				  
visualizeBoard (player, (hw:tw) , (hb:tb)) = putStrLn(header++"\n"++row8++"\n"++row7++"\n"++row6++"\n"++row5++"\n"++row4++"\n"++row3++"\n"++row2++"\n"++row1++"\n"++footer)
					
					where{
					header = "     a    b    c    d    e    f    g    h	\n";
					row8 = "8 |"++ (rowPrint (hw:tw) (hw:tw) (hb:tb) (hb:tb) 8 'a')++"\n";
					row7 = "7 |"++ (rowPrint (hw:tw) (hw:tw) (hb:tb) (hb:tb) 7 'a')++"\n";
					row6 = "6 |"++ (rowPrint (hw:tw) (hw:tw) (hb:tb) (hb:tb) 6 'a')++"\n";
					row5 = "5 |"++ (rowPrint (hw:tw) (hw:tw) (hb:tb) (hb:tb) 5 'a')++"\n";
					row4 = "4 |"++ (rowPrint (hw:tw) (hw:tw) (hb:tb) (hb:tb) 4 'a')++"\n";
					row3 = "3 |"++ (rowPrint (hw:tw) (hw:tw) (hb:tb) (hb:tb) 3 'a')++"\n";
					row2 = "2 |"++ (rowPrint (hw:tw) (hw:tw) (hb:tb) (hb:tb) 2 'a')++"\n";
					row1 = "1 |"++ (rowPrint (hw:tw) (hw:tw) (hb:tb) (hb:tb) 1 'a')++"\n";
					footer="Turn: " ++show(player);
					}
					






--isLegal:: Piece -> Board -> Location -> Bool

--pawn f elstart position mmkn 1 or 2 squres or diagonal 
--pawn me4 33la elstart postion 

--we need a way to check en elpath to the place fady 

--we need a way to check en elmkan el enta ray7o mafho4 7ad mn your same team 

--we need to make sure the player in turn is the one playing

--3ayzeen nes2l if we need to handle a player byl3b me4 f doro 
--w 3ayzen nes2l 3la the first example f is legal 34an setBoard dor elfeha White bs elly le3eb black 
--do we have to make sure en el piece dy already f elboard asln ?



--f4 , bytl3 e5 w hwa me4 s7
isLegal (P (cp,ip)) board (ct, it) =if((getPlayer (cp,ip) board)==White)then( if(it>ip&&cp==ct&&(noPieceInTargetLocation board (ct,it))&&(emptyWayUp (cp,ip) (cp,ip) board (ct,it)))then (if(initialConditionForPawn (P (cp,ip)) board) then (if(it-ip==2||it-ip==1)then True else False) else (if(it-ip==1)then True else False)) else (if(((returnNext cp==ct)||(cp==returnNext ct))&&(opponentOn (getPlayer (cp,ip) board) board (ct,it)))then (if(ip+1==it)then True else False)else False))
									else (if(ip>it&&cp==ct&&(noPieceInTargetLocation board (ct,it))&&(emptyWayDown (cp,ip) (cp,ip) board (ct,it)))then (if(initialConditionForPawn (P (cp,ip)) board) then (if(ip-it==2||ip-it==1)then True else False) else (if(ip-it==1)then True else False)) else (if(((returnNext cp==ct)||(cp==returnNext ct))&&(noSameTeam (cp,ip) board (ct,it)))then (if(ip+1==it)then True else False)else False))
									
											
isLegal (K currentLocation) board (ct, it) = if ((noSameTeam currentLocation board (ct, it)) && ((ct == returnNext (getX currentLocation) && it == getY currentLocation) || (ct == returnNext (getX currentLocation) && it == (getY currentLocation) + 1) || (ct == returnNext (getX currentLocation) && it == (getY currentLocation) - 1) || (ct == getX currentLocation && it == (getY currentLocation) +1) ||	(ct == getX currentLocation && it == (getY currentLocation) - 1) || (returnNext ct == getX currentLocation && it == (getY currentLocation) + 1) || (returnNext ct == getX currentLocation && it == (getY currentLocation) - 1) || (returnNext ct == getX currentLocation && it == getY currentLocation)) )then True else False


isLegal(N currentLocation) board (ct,it) | (noSameTeam currentLocation board (ct,it))&&(((returnNext (returnNext ct)==(getX currentLocation))||(ct== returnNext (returnNext (getX currentLocation))))&&((it==(getY currentLocation)-1)||(it==(getY currentLocation)+1)))=True
										 | (noSameTeam currentLocation board (ct,it))&&(((ct==returnNext (getX currentLocation))||(returnNext ct==(getX currentLocation)))&&((it==(getY currentLocation)-2)||(it==(getY currentLocation)+2)))=True
										 |  otherwise=False


isLegal(R (cp,ip)) board (ct,it)=if(noSameTeam (cp,ip) board (ct,it)) 
								then (if(ct==cp)then(if (it>ip) then (emptyWayUp (cp,ip) (cp,ip) board (ct,it))else  (emptyWayDown (cp,ip) (cp,ip) board (ct,it))) else (if(ip==it)then(if(ord cp<ord ct) then (emptyWayRight (cp,ip) (cp,ip) board (ct,it))else (emptyWayLeft (cp,ip) (cp,ip) board (ct,it)))else False))
								else False



isLegal (B (cp,ip)) board (ct,it)= if(cp==ct||ip==it)then(False)else(if(noSameTeam (cp,ip) board (ct,it))
								   then (if (ord cp < ord ct) 
								   then (if (ip<it) then (emptyWayUpRight (cp,ip)(cp,ip) board (ct,it)) 
								   else ( emptyWayDownRight (cp,ip) (cp,ip) board (ct,it) ))
								   --the next else is for the cases of left up and down 
								   else(if(ip<it)then (emptyWayUpLeft (cp,ip) (cp,ip) board (ct,it))else(emptyWayDownLeft (cp,ip) (cp,ip) board (ct,it) )))
								   else False)


isLegal(Q (cp,ip)) board (ct,it)=if(noSameTeam (cp,ip) board (ct,it)) 
								then (if(ct==cp)then(if (it>ip) then (emptyWayUp (cp,ip) (cp,ip) board (ct,it))else  (emptyWayDown (cp,ip) (cp,ip) board (ct,it))) else (if(ip==it)then(if(ord cp<ord ct) then (emptyWayRight (cp,ip) (cp,ip) board (ct,it))else (emptyWayLeft (cp,ip) (cp,ip) board (ct,it)))else (isLegalDiagonal (Q (cp,ip)) board (ct,it))))
								else False



isLegalDiagonal (Q (cp,ip)) board (ct,it)= if(cp==ct||ip==it)then(False)else(if(noSameTeam (cp,ip) board (ct,it))
								   then (if (ord cp < ord ct) 
								   then (if (ip<it) then (emptyWayUpRight (cp,ip)(cp,ip) board (ct,it)) 
								   else ( emptyWayDownRight (cp,ip) (cp,ip) board (ct,it) ))
								   --the next else is for the cases of left up and down 
								   else(if(ip<it)then (emptyWayUpLeft (cp,ip) (cp,ip) board (ct,it))else(emptyWayDownLeft (cp,ip) (cp,ip) board (ct,it) )))
								   else False)






suggestMove piece board = suggestMoveHelper piece board getAllLocations

suggestMoveHelper piece board [] = []
suggestMoveHelper piece board (l:ls) = if (isLegal piece board l) then (l:suggestMoveHelper piece board ls)
                                       else suggestMoveHelper piece board ls

move :: Piece -> Location -> Board -> Board
move (P location) targetLocation (White, whites, blacks) = if not (elem (P location) whites) then error "This is white player's turn, black can't move" else moveWhite (P location) targetLocation (White, whites, blacks)
move (P location) targetLocation (Black, whites, blacks) = if not (elem (P location) blacks) then error "This is black player's turn, white can't move" else moveBlack (P location) targetLocation (Black, whites, blacks)
														
move (N location) targetLocation (White, whites, blacks) = if not (elem (N location) whites) then error "This is white player's turn, black can't move" else moveWhite (N location) targetLocation (White, whites, blacks)
move (N location) targetLocation (Black, whites, blacks) = if not (elem (N location) blacks) then error "This is black player's turn, white can't move" else moveBlack (N location) targetLocation (Black, whites, blacks)
														
move (N location) targetLocation (White, whites, blacks) = if not (elem (K location) whites) then error "This is white player's turn, black can't move" else moveWhite (K location) targetLocation (White, whites, blacks)
move (N location) targetLocation (Black, whites, blacks) = if not (elem (K location) blacks) then error "This is black player's turn, white can't move" else moveBlack (K location) targetLocation (Black, whites, blacks)

move (R location) targetLocation (White, whites, blacks) = if not (elem (R location) whites) then error "This is white player's turn, black can't move" else moveWhite (R location) targetLocation (White, whites, blacks)
move (R location) targetLocation (Black, whites, blacks) = if not (elem (R location) blacks) then error "This is black player's turn, white can't move" else moveBlack (R location) targetLocation (Black, whites, blacks)

move (B location) targetLocation (White, whites, blacks) = if not (elem (B location) whites) then error "This is white player's turn, black can't move" else moveWhite (B location) targetLocation (White, whites, blacks)
move (B location) targetLocation (Black, whites, blacks) = if not (elem (B location) blacks) then error "This is black player's turn, white can't move" else moveBlack (B location) targetLocation (Black, whites, blacks)

move (Q location) targetLocation (White, whites, blacks) = if not (elem (Q location) whites) then error "This is white player's turn, black can't move" else moveWhite (Q location) targetLocation (White, whites, blacks)
move (Q location) targetLocation (Black, whites, blacks) = if not (elem (Q location) blacks) then error "This is black player's turn, white can't move" else moveBlack (Q location) targetLocation (Black, whites, blacks)
														

moveWhite :: Piece -> Location -> Board -> Board
moveWhite (P location) targetLocation (White, whites, blacks) = if not (isLegal (P location) (White, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardWhite (P location) targetLocation (Black, whites, blacks)
									
											
moveWhite (N location) targetLocation (White, whites, blacks) = if not (isLegal (N location) (White, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardWhite (N location) targetLocation (Black, whites, blacks)
																
															
moveWhite (K location) targetLocation (White, whites, blacks) = if not (isLegal (K location) (White, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardWhite (K location) targetLocation (Black, whites, blacks)
																

moveWhite (R location) targetLocation (White, whites, blacks) = if not (isLegal (R location) (White, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardWhite (R location) targetLocation (Black, whites, blacks)
																

moveWhite (B location) targetLocation (White, whites, blacks) = if not (isLegal (B location) (White, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardWhite (B location) targetLocation (Black, whites, blacks)
																
																
moveWhite (Q location) targetLocation (White, whites, blacks) = if not (isLegal (Q location) (White, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardWhite (Q location) targetLocation (Black, whites, blacks)
																

moveBlack :: Piece -> Location -> Board -> Board
moveBlack (P location) targetLocation (Black, whites, blacks) = if not (isLegal (P location) (Black, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardBlack (P location) targetLocation (White, whites, blacks)
																
																
moveBlack (N location) targetLocation (Black, whites, blacks) = if not (isLegal (N location) (Black, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardBlack (N location) targetLocation (White, whites, blacks)
																
																
moveBlack (K location) targetLocation (Black, whites, blacks) = if not (isLegal (K location) (Black, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardBlack (K location) targetLocation (White, whites, blacks)
																
																
moveBlack (R location) targetLocation (Black, whites, blacks) = if not (isLegal (R location) (Black, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardBlack (R location) targetLocation (White, whites, blacks)
																
																
moveBlack (B location) targetLocation (Black, whites, blacks) = if not (isLegal (B location) (Black, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardBlack (B location) targetLocation (White, whites, blacks)
																
																
moveBlack (Q location) targetLocation (Black, whites, blacks) = if not (isLegal (Q location) (Black, whites, blacks) targetLocation) then error "Illegal move for piece " else updateBoardBlack (Q location) targetLocation (White, whites, blacks)
																
																

updateBoardWhite :: Piece -> Location -> Board -> Board													
updateBoardWhite (P location) targetLocation (Black, whites, blacks) =  if occursIn targetLocation blacks then (Black, newWhite, newBlack) else (Black, newWhite, blacks)
																			where 
																			newWhite = ((P targetLocation):(removeElement (P location) whites))
																			newBlack = removeWithLoc targetLocation blacks

updateBoardWhite (N location) targetLocation (Black, whites, blacks) =  if occursIn targetLocation blacks then (Black, newWhite, newBlack) else (Black, newWhite, blacks)
																	where 
																	newWhite = ((N targetLocation):(removeElement (N location) whites))
																	newBlack = removeWithLoc targetLocation blacks
																	
updateBoardWhite (K location) targetLocation (Black, whites, blacks) =  if occursIn targetLocation blacks then (Black, newWhite, newBlack) else (Black, newWhite, blacks)
																	where 
																	newWhite = ((K targetLocation):(removeElement (K location) whites))
																	newBlack = removeWithLoc targetLocation blacks
																	
updateBoardWhite (R location) targetLocation (Black, whites, blacks) =  if occursIn targetLocation blacks then (Black, newWhite, newBlack) else (Black, newWhite, blacks)
																	where 
																	newWhite = ((R targetLocation):(removeElement (R location) whites))
																	newBlack = removeWithLoc targetLocation blacks
																	
updateBoardWhite (B location) targetLocation (Black, whites, blacks) =  if occursIn targetLocation blacks then (Black, newWhite, newBlack) else (Black, newWhite, blacks)
																	where 
																	newWhite = ((B targetLocation):(removeElement (B location) whites))
																	newBlack = removeWithLoc targetLocation blacks
																	
updateBoardWhite (Q location) targetLocation (Black, whites, blacks) =  if occursIn targetLocation blacks then (Black, newWhite, newBlack) else (Black, newWhite, blacks)
																	where 
																	newWhite = ((Q targetLocation):(removeElement (Q location) whites))
																	newBlack = removeWithLoc targetLocation blacks
																	
											

updateBoardBlack :: Piece -> Location -> Board -> Board													
updateBoardBlack (P location) targetLocation (White, whites, blacks) =  if occursIn targetLocation whites then (White, newWhite, newBlack) else (White, newWhite, blacks)
																		where 
																		newWhite = removeWithLoc targetLocation whites
																		newBlack = ((P targetLocation): (removeElement (P location) blacks))
																		
updateBoardBlack (N location) targetLocation (White, whites, blacks) =  if occursIn targetLocation whites then (White, newWhite, newBlack) else (White, newWhite, blacks)
																		where 
																		newWhite = removeWithLoc targetLocation whites
																		newBlack = ((N targetLocation): (removeElement (N location) blacks))
																		
updateBoardBlack (K location) targetLocation (White, whites, blacks) =  if occursIn targetLocation whites then (White, newWhite, newBlack) else (White, newWhite, blacks)
																		where 
																		newWhite = removeWithLoc targetLocation whites
																		newBlack = ((K targetLocation): (removeElement (K location) blacks))
																		
updateBoardBlack (R location) targetLocation (White, whites, blacks) =  if occursIn targetLocation whites then (White, newWhite, newBlack) else (White, newWhite, blacks)
																		where 
																		newWhite = removeWithLoc targetLocation whites
																		newBlack = ((R targetLocation): (removeElement (R location) blacks))
																		
updateBoardBlack (B location) targetLocation (White, whites, blacks) =  if occursIn targetLocation whites then (White, newWhite, newBlack) else (White, newWhite, blacks)
																		where 
																		newWhite = removeWithLoc targetLocation whites
																		newBlack = ((B targetLocation): (removeElement (B location) blacks))

updateBoardBlack (Q location) targetLocation (White, whites, blacks) =  if occursIn targetLocation whites then (White, newWhite, newBlack) else (White, newWhite, blacks)
																		where 
																		newWhite = removeWithLoc targetLocation whites
																		newBlack = ((Q targetLocation): (removeElement (Q location) blacks))																		


removeElement :: Piece -> [Piece] -> [Piece]
removeElement _ [] = [] 
removeElement x (y:ys)
  | x == y    = removeElement x ys 
  | otherwise = y : removeElement x ys 
  
occursIn :: Location -> [Piece] -> Bool
occursIn location [] = False
occursIn location ((P targetLocation): t) = if (getX location == getX targetLocation && getY location == getY targetLocation) then True else occursIn location t
occursIn location ((N targetLocation): t) = if (getX location == getX targetLocation && getY location == getY targetLocation) then True else occursIn location t
occursIn location ((K targetLocation): t) = if (getX location == getX targetLocation && getY location == getY targetLocation) then True else occursIn location t
occursIn location ((R targetLocation): t) = if (getX location == getX targetLocation && getY location == getY targetLocation) then True else occursIn location t
occursIn location ((B targetLocation): t) = if (getX location == getX targetLocation && getY location == getY targetLocation) then True else occursIn location t
occursIn location ((Q targetLocation): t) = if (getX location == getX targetLocation && getY location == getY targetLocation) then True else occursIn location t

removeWithLoc :: Location -> [Piece] -> [Piece]
removeWithLoc location [] = []
removeWithLoc location ((P targetLocation) : t)  =  if (getX location == getX targetLocation && getY location == getY targetLocation) then removeElement (P location) ((P targetLocation) : t) else ((P targetLocation):removeWithLoc location t)
								  
removeWithLoc location ((N targetLocation) : t)  =  if (getX location == getX targetLocation && getY location == getY targetLocation) then removeElement (N location) ((N targetLocation) : t) else ((N targetLocation):removeWithLoc location t)

removeWithLoc location ((K targetLocation) : t)  =  if (getX location == getX targetLocation && getY location == getY targetLocation) then removeElement (K location) ((K targetLocation) : t) else ((K targetLocation):removeWithLoc location t)

removeWithLoc location ((R targetLocation) : t)  =  if (getX location == getX targetLocation && getY location == getY targetLocation) then removeElement (R location) ((R targetLocation) : t) else ((R targetLocation):removeWithLoc location t)

removeWithLoc location ((B targetLocation) : t)  =  if (getX location == getX targetLocation && getY location == getY targetLocation) then removeElement (B location) ((B targetLocation) : t) else ((B targetLocation):removeWithLoc location t)

removeWithLoc location ((Q targetLocation) : t)  =  if (getX location == getX targetLocation && getY location == getY targetLocation) then removeElement (Q location) ((Q targetLocation) : t) else ((Q targetLocation):removeWithLoc location t)


--HELPERS
	
initialConditionForPawn (P (c,i)) (player, _, _)	   |(show(player)=="White")&&(i==2)&&(c=='a')= True
													   |(show(player)=="White")&&(i==2)&&(c=='b')= True
													   |(show(player)=="White")&&(i==2)&&(c=='c')= True
											           |(show(player)=="White")&&(i==2)&&(c=='d')= True
											           |(show(player)=="White")&&(i==2)&&(c=='e')= True
													   |(show(player)=="White")&&(i==2)&&(c=='f')= True
												       |(show(player)=="White")&&(i==2)&&(c=='g')= True
												   	   |(show(player)=="White")&&(i==2)&&(c=='h')= True
														  
													   |(show(player)=="Black")&&(i==7)&&(c=='a')= True
													   |(show(player)=="Black")&&(i==7)&&(c=='b')= True
												       |(show(player)=="Black")&&(i==7)&&(c=='c')= True
													   |(show(player)=="Black")&&(i==7)&&(c=='d')= True
												       |(show(player)=="Black")&&(i==7)&&(c=='e')= True
											     	   |(show(player)=="Black")&&(i==7)&&(c=='f')= True
													   |(show(player)=="Black")&&(i==7)&&(c=='g')= True
													   |(show(player)=="Black")&&(i==7)&&(c=='h')= True
													   |otherwise=False
															




noPieceInTargetLocation:: Board-> Location -> Bool
noPieceInTargetLocation (player,[],[]) location=True
noPieceInTargetLocation (player,[],(b:bs)) (c,i)=if((getX (getLocation b)==c)&&(getY (getLocation b)==i))then False else noPieceInTargetLocation (player,[],bs) (c,i)
noPieceInTargetLocation (player,(w:ws),[]) (c,i)=if((getX (getLocation w)==c)&&(getY (getLocation w)==i))then False else noPieceInTargetLocation (player,ws,[]) (c,i)
noPieceInTargetLocation (player,(w:ws),(b:bs)) (c,i)=if((getX (getLocation w)==c)&&(getY (getLocation w)==i))then False else noPieceInTargetLocation (player,ws,(b:bs)) (c,i)




noSameTeam location baord@(player,[], []) targetLocation=True
noSameTeam location board@(player,[], (b:bs)) targetLocation = if((getPlayer location board)==White)then True else  noSameTeam2 Black board targetLocation
noSameTeam location board@(player ,(w:ws) ,[]) targetLocation = if((getPlayer location board)==Black)then True else  noSameTeam2 White board targetLocation
noSameTeam location board@(player1 ,(w:ws) ,(b:bs)) targetLocation =if (show(player)=="White") then(if (whiteLocationX==(getX targetLocation)&& whiteLocationY==(getY targetLocation)) then False else noSameTeam2 player (player1,ws,(b:bs)) targetLocation)
													else 
													if (blackLocationX ==(getX targetLocation) && blackLocationY ==(getY targetLocation)) then False
													else noSameTeam2 player (player1,(w:ws),bs) targetLocation
													
													where{
														whiteLocationX=getX (getLocation w);
														whiteLocationY=getY (getLocation w);
														blackLocationX=getX (getLocation b);
														blackLocationY=getY (getLocation b);
														player=getPlayer location board;
													}
noSameTeam2 location baord@(player,[], []) targetLocation=True
noSameTeam2 player (player1,[], (b:bs)) targetLocation = if(player==White)then True else  (if (blackLocationX ==(getX targetLocation) && blackLocationY ==(getY targetLocation)) then False
																							else noSameTeam2 player (player1,[],bs) targetLocation)
														where{
														
														blackLocationX=getX (getLocation b);
														blackLocationY=getY (getLocation b);
													}	
													
noSameTeam2 player (player1 ,(w:ws) ,[]) targetLocation = if(player==Black)then True else  (if (whiteLocationX ==(getX targetLocation) && whiteLocationY ==(getY targetLocation)) then False
																							else noSameTeam2 player (player1,ws,[]) targetLocation)
														where{
														
														whiteLocationX=getX (getLocation w);
														whiteLocationY=getY (getLocation w);
													}	 
noSameTeam2 player board@(player1 ,(w:ws) ,(b:bs)) targetLocation =if (show(player)=="White") then(if (whiteLocationX==(getX targetLocation)&& whiteLocationY==(getY targetLocation)) then False else noSameTeam2 player (player1,ws,(b:bs)) targetLocation)
													else 
													if (blackLocationX ==(getX targetLocation) && blackLocationY ==(getY targetLocation)) then False
													else noSameTeam2 player (player1,(w:ws),bs) targetLocation
													
													where{
														whiteLocationX=getX (getLocation w);
														whiteLocationY=getY (getLocation w);
														blackLocationX=getX (getLocation b);
														blackLocationY=getY (getLocation b);
														
													}		

opponentOn player (player1,[], _) targetLocation = False
opponentOn player (player1 ,_ ,[]) targetLocation = False
opponentOn player board@(player1 ,(w:ws) ,(b:bs)) targetLocation =if (show(player)=="Black") then(if (whiteLocationX==(getX targetLocation)&& whiteLocationY==(getY targetLocation)) then True else opponentOn player (player1,ws,(b:bs)) targetLocation)
													else 
													if (blackLocationX ==(getX targetLocation) && blackLocationY ==(getY targetLocation)) then True
													else opponentOn player (player1,(w:ws),bs) targetLocation
													
													where{
														whiteLocationX=getX (getLocation w);
														whiteLocationY=getY (getLocation w);
														blackLocationX=getX (getLocation b);
														blackLocationY=getY (getLocation b);
														
													}														
												

rowPrint [] (w1:ws1) [] (b1:bs1) n 'h' = "    |" 




rowPrint ((P (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then " PW |" else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n 'h')
rowPrint [] (w1:ws1) ((P (c1,n1)):bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then  " PB |" else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n 'h') 



rowPrint ((R (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then " RW |" else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n 'h')
rowPrint [] (w1:ws1) ((R (c1,n1)):bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then  " RB |" else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n 'h') 


rowPrint ((K (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then " KW |" else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n 'h')
rowPrint [] (w1:ws1) ((K (c1,n1)):bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then  " KB |" else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n 'h') 


rowPrint ((N (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then " NW |" else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n 'h')
rowPrint [] (w1:ws1) ((N (c1,n1)):bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then  " NB |" else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n 'h') 


rowPrint ((Q (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then " QW |" else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n 'h')
rowPrint [] (w1:ws1) ((Q (c1,n1)):bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then  " QB |" else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n 'h')

rowPrint ((B (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then " BW |" else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n 'h')
rowPrint [] (w1:ws1) ((B (c1,n1)):bs) (b1:bs1) n 'h'= if (c1 == 'h' && n1 == n) then  " BB |" else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n 'h') 


--this is the base case for any column other than h
rowPrint [] (w1:ws1) [] (b1:bs1) n c = "    |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c ))




rowPrint ((P (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n c= if (c1 == c && n1 == n) then " PW |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n c)
rowPrint [] (w1:ws1) ((P (c1,n1)):bs) (b1:bs1) n c= if (c1 == c && n1 == n) then  " PB |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n c) 



rowPrint ((R (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n c= if (c1 == c && n1 == n) then " RW |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n c)
rowPrint [] (w1:ws1) ((R (c1,n1)):bs) (b1:bs1) n c= if (c1 == c && n1 == n) then  " RB |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n c) 


rowPrint ((K (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n c= if (c1 == c && n1 == n) then " KW |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n c)
rowPrint [] (w1:ws1) ((K (c1,n1)):bs) (b1:bs1) n c= if (c1 == c && n1 == n) then  " KB |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n c) 


rowPrint ((N (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n c= if (c1 == c && n1 == n) then " NW |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n c)
rowPrint [] (w1:ws1) ((N (c1,n1)):bs) (b1:bs1) n c= if (c1 == c && n1 == n) then  " NB |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n c) 


rowPrint ((Q (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n c= if (c1 == c && n1 == n) then " QW |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n c)
rowPrint [] (w1:ws1) ((Q (c1,n1)):bs) (b1:bs1) n c= if (c1 == c && n1 == n) then  " QB |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n c)

rowPrint ((B (c1,n1)):ws) (w1:ws1) (b:bs) (b1:bs1) n c= if (c1 == c && n1 == n) then " BW |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint ws (w1:ws1) (b:bs) (b1:bs1) n c)
rowPrint [] (w1:ws1) ((B (c1,n1)):bs) (b1:bs1) n c= if (c1 == c && n1 == n) then  " BB |" ++ (rowPrint (w1:ws1) (w1:ws1) (b1:bs1) (b1:bs1) n (returnNext c )) else (rowPrint [] (w1:ws1) (bs) (b1:bs1) n c) 




--lessa hane3melha
--emptyWayUp->location->board->location->Bool
--IMPORTANT NOTE: we are not sure if the idea of returnNext c in the input will work , may need to implement returnPrevious
emptyWayUp (c, i) l@(c2,i2) board (c1, i1)=if(c==c1&&(i+1)==i1)then noSameTeam l board (c1, i1) else emptyWayUp2 (c, i) l board (c1, i1)
emptyWayUp2 (c, i) l@(c2,i2) board targetLocation |noPieceInTargetLocation board (c,i+1)=emptyWayUp (c,i+1) l board targetLocation
								        |otherwise=False


emptyWayDown (c, i) l@(c2,i2) board (c1, i1)=if(c==c1&&(i-1)==i1)then (noSameTeam l board (c1, i1)) else emptyWayDown2 (c, i) l board (c1, i1)
emptyWayDown2 (c, i) l@(c2,i2) board targetLocation |noPieceInTargetLocation board (c, i-1)=(emptyWayDown (c,i-1) l board targetLocation)
								          |otherwise=False

										 
emptyWayRight (c, i) l@(c2,i2) board (c1, i1)=if((returnNext c)==c1&&i==i1)then noSameTeam l board (c1, i1) else emptyWayRight2 (c, i) l board (c1, i1)
emptyWayRight2 (c, i) l@(c2,i2) board targetLocation |noPieceInTargetLocation board (returnNext c, i)=emptyWayRight (returnNext c,i) l board targetLocation
								           |otherwise=False

emptyWayLeft (c, i) l@(c2,i2) board (c1, i1)=if((pred c)==c1&&i==i1)then noSameTeam l board (c1, i1) else emptyWayLeft2 (c, i) l board (c1, i1)
emptyWayLeft2 (c, i) l@(c2,i2) board targetLocation |noPieceInTargetLocation board (pred c, i)=emptyWayLeft (pred c,i) l board targetLocation
									   	  |otherwise=False



emptyWayUpRight (c, i) l@(c2,i2) board (c1, i1)=if(c==c1||i==i1)then(False)else(if((returnNext c)==c1&&(i+1)==i1)then noSameTeam l board (c1, i1) else emptyWayUpRight2 (c, i) l board (c1, i1))
emptyWayUpRight2 (c, i) l@(c2,i2) board targetLocation |noPieceInTargetLocation board (returnNext c, i+1)=emptyWayUpRight (returnNext c,i+1) l board targetLocation
											 |otherwise=False
											
emptyWayDownRight (c, i) l@(c2,i2) board (c1, i1)=if(c==c1||i==i1)then(False)else if((returnNext c)==c1&&(i-1)==i1)then noSameTeam l board (c1, i1) else emptyWayDownRight2 (c, i) l board (c1, i1)
emptyWayDownRight2 (c, i) l@(c2,i2) board targetLocation |noPieceInTargetLocation board (returnNext c, i-1)=emptyWayDownRight (returnNext c,i-1) l board targetLocation
											   |otherwise=False
											  
emptyWayUpLeft (c, i) l@(c2,i2) board (c1, i1)=if(c==c1||i==i1)then(False)else if((pred c)==c1&&(i+1)==i1)then noSameTeam l board (c1, i1) else emptyWayUpLeft2 (c, i) l board (c1, i1)
emptyWayUpLeft2 ( c, i) l@(c2,i2) board targetLocation |noPieceInTargetLocation board (pred c, i+1)=emptyWayUpLeft (pred c,i+1) l board targetLocation
										   |otherwise=False
											
emptyWayDownLeft (c, i) l@(c2,i2) board (c1, i1)=if(c==c1||i==i1)then(False)else if((pred c)==c1&&(i-1)==i1)then noSameTeam l board (c1, i1) else emptyWayDownLeft2 (c, i) l board (c1, i1)
emptyWayDownLeft2 (c, i) l@(c2,i2) board targetLocation |noPieceInTargetLocation board (pred c, i-1)=emptyWayDownLeft (pred c,i-1) l board targetLocation
											 |otherwise=False
			

getAllLocations::[(Char,Int)]

getAllLocations = [('a',1),('a',2),('a',3),('a',4),('a',5),('a',6),('a',7),('a',8),
                   ('b',1),('b',2),('b',3),('b',4),('b',5),('b',6),('b',7),('b',8),
                   ('c',1),('c',2),('c',3),('c',4),('c',5),('c',6),('c',7),('c',8),
                   ('d',1),('d',2),('d',3),('d',4),('d',5),('d',6),('d',7),('d',8),
                   ('e',1),('e',2),('e',3),('e',4),('e',5),('e',6),('e',7),('e',8),
                   ('f',1),('f',2),('f',3),('f',4),('f',5),('f',6),('f',7),('f',8),
                   ('g',1),('g',2),('g',3),('g',4),('g',5),('g',6),('g',7),('g',8),
                   ('h',1),('h',2),('h',3),('h',4),('h',5),('h',6),('h',7),('h',8)]
			
			
			
returnNext c = chr(ord c+1)

removePunc :: String -> String
removePunc xs = filter (/= '\t') xs

getLocation:: Piece->Location
getLocation (P location) = location
getLocation (N location) = location
getLocation (K location) = location
getLocation (Q location) = location
getLocation (R location) = location
getLocation (B location) = location

piecePrint (P (c,r))="P"
piecePrint (N (c,r))="N"
piecePrint (K (c,r))="K"
piecePrint (Q (c,r))="Q"
piecePrint (R (c,r))="R"
piecePrint (B (c,r))="B"

getX:: Location->Char
getX (c, i) = c

getY:: Location->Int
getY (c, i) = i



getPlayer:: Location->Board->Player
getPlayer location@(c,i) board@(player1,[],[])= error "The piece is not on the board"
getPlayer location@(c,i) board@(player1,(w:ws),[])=if(getLocation w==location)then White else getPlayer location (player1,ws,[])
getPlayer location@(c,i) board@(player1,[],(b:bs)) =if(getLocation b==location)then Black else getPlayer location (player1,[],bs)
getPlayer location@(c,i) board@(player1,(w:ws),(b:bs))=if(getLocation w==location)then White else getPlayer location (player1,ws,(b:bs))

