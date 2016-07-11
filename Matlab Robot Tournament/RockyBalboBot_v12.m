function [out] = RockyBalboBot_v12(self, enemy, tank, mine)

%% CHANGES IN V12
%transferred the changes from v11 to v12 about T2

%% PARAMETERS

%set parameters for fuel consumption
params.speed_fuel = 2.5;
params.speed_awaymine = 1.4;
params.speed_enemy = 3;
params.speed_crawl = 0.2;

%set parameters for distances
params.dist_mine = 4;
params.dist_enemy = 12;
params.dist_far = 20;

%distances
%d1 = norm(self.pos - enemy.pos);
%d2 = norm(self.prev - enemy.prev);

%reference vectors
v1 = self.pos - self.prev;
v2 = enemy.pos - enemy.prev;

%% LOOPING

%look for closest tank, assign it to T
if ~isempty(tank)
    
    a = inf;
    T=0;
    
    for i = 1:length(tank)
        
        % get distance to ith fuel tank
        A = norm(tank(i).pos - self.pos);
        if  A < a
            a = A;
            T = i;
        end %if
    end %for
    
    x = inf;
    T2 = 0;
   
    for y = 1:length(tank)
       
        %get distance to the xth fuel tank
        X = norm(tank(y).pos - self.pos);
        if X < x && X > norm(tank(T).pos - self.pos)
            x = X;
            T2 = y;
        end %if
    end %for
    
   
    
end %tank loop
 dist_tank=norm(tank(T).pos-self.pos);




%look for closest mine, assign it to M
if ~isempty(mine)
    
    b = inf;
    M = 0;
    
    for j = 1:length(mine)
        
        % get distance to this fuel tank
        B = norm(mine(j).pos - self.pos);
        if  B < b
            b = B;
            M = j;
        end %if
    end %for

    %for w=1:length(mine)
    %gendirmx=sum(mine(w).pos(1)-self.pos(1));
    %gendirmy=sum(mine(w).pos(2)-self.pos(2));
    % end %for gendirt
end %mine loop


%% MOVEMENT

if norm(self.pos - enemy.pos) <= params.dist_enemy %enemy within attacking distance
    
    if self.fuel > enemy.fuel %enemy has less fuel
        out = moveEnemy(self,enemy,'to',params.speed_enemy);
        
    else %enemy has more fuel
        
        check = orthoCheck(v1,v2);
        
        if check == 1 %angle between vectors is less than pi/8
            
            if norm(mine(M).pos-self.pos) <= params.dist_mine %within distance of mine
                out = awayMine(self, mine, M, params.speed_awaymine) + moveEnemy(self, enemy,'away', params.speed_enemy);
                
            else %not within distance of mine
                
                out = moveEnemy(self, enemy, 'away', params.speed_enemy);
                
            end %mine within distance
            
        else %angle between vectors is greater than pi/8
            
            if norm(mine(M).pos-self.pos) <= params.dist_mine %within distance of mine
                out = awayMine(self, mine, M, params.speed_awaymine);
                
            else %not within mine distance
                
                if ~isempty(tank) %enemy more fuel, tanks present on field
                    
                    
                    if dist_tank<= 5
                        out = toTank(self, tank, T, params.speed_fuel);
                    else
                        out = gendirt(self,tank,params.speed_fuel,dist_tank);
                    end %checking to see if closest mine is within 8, otherwise move in gendirection
                    
                else %enemy more fuel, no tanks present
                    out = moveEnemy(self, enemy, 'away', params.speed_crawl);
                    
                end %if tanks exist
            end %if mine within distance
        end %if orthoCheck
    end %if fuel compare
    
else %enemy not within distance
    
    if norm(mine(M).pos-self.pos) <= params.dist_mine %within distance of mine
        
        if mine(M).val >= 50 %mine greater than 50
            out = awayMine(self, mine, M, params.speed_awaymine);
            
        else %mine less than 50
            if length(tank) >= 2 %2 or more tanks present
                
                if norm(enemy.pos - tank(T).pos) < norm(self.pos - tank(T).pos); %enemy closer to tank T
                    out = toTank(self, tank, T2, params.speed_fuel);
                    
                else %we are closer to tank T
                    out = toTank(self, tank, T, params.speed_fuel);
                    
                end %enemy closer to tank
                
            elseif length(tank) == 1 %one tank remaining
                
                if norm(enemy.pos - tank(T).pos) < norm(self.pos - tank(T).pos); %enemy closer to tank T
                    out = moveEnemy(self, enemy, 'to', params.speed_crawl);
                    
                else %we are closer to last tank
                    out = toTank(self, tank, T, params.speed_fuel);
                    
                end % enemy closer to last remaining tank
                
                
            else %no tanks pressent
                if self.fuel < enemy.fuel %enemy has less fuel
                    out = moveEnemy(self, enemy, 'to', params.speed_enemy);
                    
                else %enemy has more fuel
                    out = moveEnemy(self, enemy, 'away', params.speed_crawl);
                    
                end %if fuel compare
            end %if tank presence
        end %if mine value
    else %not within distance of mine
        
        if length(tank) == 1 %one tank remaining
            
            if norm(self.pos-tank(T).pos) < norm(tank(T).pos-enemy.pos) %tank closer than enemy
                out = toTank(self, tank, T, params.speed_fuel);
                
            else %enemy closer to tank T
                out = moveEnemy(self, enemy, 'away', params.speed_crawl);
                
            end %if distance compare
            
        elseif length(tank) >= 2 %2 or more tanks remaining
            
            if norm(enemy.pos - tank(T).pos) < norm(self.pos - tank(T).pos); %enemy closer to tank T
                out = toTank(self, tank, T2, params.speed_fuel);
                
            else %we are closer to tank T
                out = toTank(self, tank, T, params.speed_fuel);
                
            end %enemy closer to tank
            
        else %no tanks present
            out = moveEnemy(self, enemy, 'to', params.speed_crawl);
            
        end %if tanks presence
    end %if mine within distance
end %if enemy within distance



end % function

%% SUBFUNCTIONS

function [out] = toTank(self, tank, T, speed)

%distance to fuel tank T
d = norm(tank(T).pos - self.pos);

%move towards fuel tank T
dx = (speed/d)*(tank(T).pos(1)-self.pos(1));
dy = (speed/d)*(tank(T).pos(2)-self.pos(2));

%assign output
out = [dx, dy];

end %toTank

function [out] = awayMine(self, mine, M, speed)

%distance to mine M
d = norm(mine(M).pos - self.pos);

%move towards mine M
dx = (speed/d)*(mine(M).pos(1)-self.pos(1));
dy = (speed/d)*(mine(M).pos(2)-self.pos(2));

%assign output
out = [-dy, dx];

end %awayMine

function [out] = moveEnemy(self,enemy,option, speed)

%distance between self and enemy
d = norm(enemy.pos - self.pos);

%movement towards/away from enemy
dx = (speed/d)*(enemy.pos(1)-self.pos(1));
dy = (speed/d)*(enemy.pos(2)-self.pos(2));

%use option to assign output
if strcmp(option, 'away')
    out = [-dx, -dy];
elseif strcmp(option,'to')
    out = [dx, dy];
end %if

end %moveEnemy

function [out] = orthoCheck(v1,v2)

d = 0;

for i = 1:length(v1)
    d = d + v1(i)*v2(i);
end %for i

theta = acos(d/((sum(v1.^2)*(sum(v2.^2)))));

if theta <= pi/8
    out = 1;
else
    out = 0;
end %if

end %orthoCheck

function [out]= gendirt(self,tank,speed,dist)
for k=1:length(tank)
    
    
   dx = (speed/dist)*sum(tank(k).pos(1)-self.pos(1));
   dy = (speed/dist)*sum(tank(k).pos(2)-self.pos(2));
%end %for general direction

out=[dx,dy];
end
end