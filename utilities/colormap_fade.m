function mymap = colormap_fade(color_plus, color_minus)

for color_i = 1:49
     mymap(color_i,:) = lighten(color_minus,(51-color_i)/50);
end
mymap(50,:) = [1,1,1];
mymap(51,:) = [1,1,1];
for color_i = 52:100
     mymap(color_i,:) = lighten(color_plus,(color_i-50)/50);
end     

end