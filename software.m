function varargout = software(varargin)
% SOFTWARE M-file for software.fig
%      SOFTWARE, by itself, creates a new SOFTWARE or raises the existing
%      singleton*.
%
%      H = SOFTWARE returns the handle to a new SOFTWARE or the handle to
%      the existing singleton*.
%
%      SOFTWARE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOFTWARE.M with the given input arguments.
%
%      SOFTWARE('Property','Value',...) creates a new SOFTWARE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before software_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to software_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help software

% Last Modified by GUIDE v2.5 12-Oct-2018 17:44:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @software_OpeningFcn, ...
                   'gui_OutputFcn',  @software_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before software is made visible.
function software_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to software (see VARARGIN)

% Choose default command line output for software
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes software wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = software_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
function uiselect_Callback(hObject, eventdata, handles)
global len M srcDir Allname
srcDir = uigetdir('Choose source directory.');   
Allname = dir(srcDir);                         
len = length(Allname) - 2;                            
n = len - 1;                                

set(handles.slid_layer,'Min',0);            
set(handles.slid_layer,'Max',n);        
set(handles.slid_layer,'SliderStep',[1/len 1/len]);   


for ii = 3:length(Allname)
    I = imread(['' srcDir '\' Allname(ii).name '']);  
    M(:,:,ii - 2) = I;                                 
end

I = imread(['' srcDir '\' Allname(3).name '']);   
axes(handles.axes_CT);
imshow(I)

function slid_layer_Callback(hObject, eventdata, handles)
global srcDir Allname n
val = get(hObject,'value');   
n = val + 3;
n = floor(n);
I = imread(['' srcDir '\' Allname(n).name '']);  
axes(handles.axes_CT);
imshow(I)

function slid_layer_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slid_thre_Callback(hObject, eventdata, handles)
global srcDir Allname n Thre
Thre = get(hObject,'value');    
Thre = floor(Thre);
set(handles.text_thre,'string',['select threshold£º',num2str(Thre)]);     

A = imread(['' srcDir '\' Allname(n).name '']);  
[a,b] = size(A);        
for i = 1:a                      
    for j = 1:b     
        if A(i,j) <= Thre            
            A(i,j) = 0;              
        end
    end
end
axes(handles.axes_CT);
imshow(A)

function slid_thre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slid_thre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in pushbutton_thre.
function pushbutton_thre_Callback(hObject, eventdata, handles)
set(handles.slid_thre,'enable','off')

function pushbutton_rethre_Callback(hObject, eventdata, handles)
set(handles.slid_thre,'enable','on')

% --- Executes on button press in pushbutton_model.
function pushbutton_model_Callback(hObject, eventdata, handles)
global M Thre fo vo PR P len
N = M(1:2:end,1:2:end,:);
limits = [NaN NaN NaN NaN NaN NaN];            
[x, y, z, D] = subvolume(N, limits);       
D = smooth3(D);

si = inputdlg({'x(mm/pixel)','y(mm/pixel)','z(mm/pixel)'},'CT parameter');
x = 2*str2num(si{1,1}).*(x - 1);                  
y = 2*str2num(si{2,1}).*(y - 1);
z = str2num(si{3,1}).*(z - 1);

[fo,vo] = isosurface(x,y,z,D,Thre);
FO = fo;
%Split
j = 1;
while ~isempty(FO)
    [vh,vl] =  find(FO == FO(1,1));
    OnePore = FO(vh,:);
    vecnum = unique(OnePore);
    vec = [FO(1,1)];
    while length(vec) ~= length(vecnum)
        vec = vecnum;
        [a,b] = size(vecnum);
        for i = 1:a
            [x,y] = find(FO == vecnum(i));
            vh = [vh;x];
        end
        vh = unique(vh);
        OnePore = FO(vh,:);
        vecnum = unique(OnePore);
    end
    P{j,1} = OnePore;
    FO(vh,:) = [];
    j = j + 1;
end

[a,b] = size(P);


for i = 1:a
    Q{i,1} = unique(P{i,1});    
end

for i = 1:a
   Point{i,1} = vo(Q{i,1}(:,1),:);  
end


for j = 1:a
    for i = 1:len
        z = Point{j,1}(:,3);
        sx = find(z == str2num(si{3,1})*(i - 1));
        ss = Point{j,1}(sx,:);
        cc(i,1) = mean(ss(:,1));
        cc(i,2) = mean(ss(:,2));
        cc(i,3) = str2num(si{3,1})*(i - 1);                                                   
        cc(i,4) = mean(sqrt((ss(:,1) - cc(i,1)).^2 + (ss(:,2) - cc(i,2)).^2));   
    end
    [m,n] = find(isnan(cc)==1);
    cc(m,:) = []; 
    PR{j,1} = cc;
    clear cc
end

[a,b] = size(PR);
for i = 1:a
    [c,d] = find(PR{i,1} == 0);
    PR{i,1}(c,:) = [];
end


[a,b] = size(PR);
for i = 1:a
    [c,d] = size(PR{i,1});
    if c == 1
        PR{i,1} = [];
    end
end


m = find(cellfun('isempty',PR) == 1);
PR(m,:) = [];
P(m,:) = [];


[a,b] = size(PR);
for i = 1:a
    [c,d] = size(PR{i,1});
    for j = 1:c - 1
        PR{i,1}(j,4) = PR{i,1}(j,4)*cos(atan(sqrt((PR{i,1}(j + 1,1) - PR{i,1}(j,1))^2 + (PR{i,1}(j + 1,2) - PR{i,1}(j,2))^2)/(PR{i,1}(j + 1,3) - PR{i,1}(j,3))));
    end
    PR{i,1}(c,4) = PR{i,1}(c,4)*cos(atan(sqrt((PR{i,1}(j + 1,1) - PR{i,1}(j,1))^2 + (PR{i,1}(j + 1,2) - PR{i,1}(j,2))^2)/(PR{i,1}(j + 1,3) - PR{i,1}(j,3))));
end

axes(handles.axes_model);
p1 = patch('Faces', fo, 'Vertices', vo,'FaceColor','red','EdgeColor','none');
daspect([0.2 0.2 0.18])
view(-40,24)
camlight(0,0)                              
camlight(90,90)
lighting gouraud
xlabel('X/mm')
ylabel('Y/mm')
zlabel('Z/mm')
alpha(0.5)

str{1,1} = ['total pore'];
for i = 1:a
    str{i + 1,1} = [num2str(i)];
end
set(handles.listbox_model,'string',str)

function listbox_model_Callback(hObject, eventdata, handles)
global fo vo P
cla reset
sel = get(gcf,'selectiontype');              
if strcmp(sel,'open')                        
    str = get(hObject, 'string');           
    n = get(hObject, 'value');             
    if n == 1
        axes(handles.axes_model);
        p1 = patch('Faces', fo, 'Vertices', vo,'FaceColor','red','EdgeColor','none');
        daspect([0.2 0.2 0.18])
        view(-40,24)
        camlight(0,0)                       
        camlight(90,90)
        lighting gouraud
        xlabel('X/mm')
        ylabel('Y/mm')
        zlabel('Z/mm')
    else
        axes(handles.axes_model);
        p1 = patch('Faces', P{n - 1,1}, 'Vertices', vo,'FaceColor','red','EdgeColor','none');
        daspect([0.2 0.2 0.18])
        view(-40,24)
        camlight(0,0)                               
        camlight(90,90)
        lighting gouraud
        xlabel('X/mm')
        ylabel('Y/mm')
        zlabel('Z/mm')
    end
end

function listbox_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton_ballmod_Callback(hObject, eventdata, handles)
global PR Ball

[m,n] = size(PR);
for k = 1:m  
    A = PR{k,1};

    [a,b] = size(A);
    
    if a == 1
        Ball{k,1} = A;
        clearvars -except PR k m Ball handles
    else
        for i = 1:4
            x = 1:a;x = x';y = A(:,i);x1 = 1:0.01:a;
            y1 = interp1(x,y,x1,'linear');
            B(:,i) = y1;
        end

        %B(:,4) = B(:,4)./2;
        N(1,:) = B(1,:);
        l = 1;
        j = 1;
        O(j,1) = 1;
        O(j,2) = B(1,4);
        [a,b] = size(B);
        for i = 2:a
            n = B(l,4) + B(i,4);
            if sqrt((B(i,1)-B(l,1))^2+(B(i,2)-B(l,2))^2+(B(i,3)-B(l,3))^2) >= n
                l = i;
                j = j + 1;
                O(j,1) = l;
                O(j,2) = B(l,4);
                N(j,:) = B(l,:);
            end
        end
        
        Ball{k,1} = N;
        clearvars -except PR k m Ball handles
    end
end

str{1,1} = ['total pore'];
for i = 1:m
    str{i + 1,1} = [num2str(i)];
end

set(handles.listbox_ballmod,'String',str);

function listbox_ballmod_Callback(hObject, eventdata, handles)
global fo vo P Ball
cla reset
sel = get(gcf,'selectiontype');             
if strcmp(sel,'open')                         
    n = get(hObject, 'value');              
    if n == 1
        axes(handles.axes_ballmod);
        p1 = patch('Faces', fo, 'Vertices', vo,'FaceColor','red','EdgeColor','none');
        daspect([0.2 0.2 0.18])
        view(-40,24)
        alpha(0.5)
        hold on
        [c,d] = size(Ball);
        for i = 1:c              
            [a,b] = size(Ball{i,1});
            for j = 1:a
                sphere1(Ball{i,1}(j,1),Ball{i,1}(j,2),Ball{i,1}(j,3),Ball{i,1}(j,4));
            end
        end
        xlabel('X/mm')
        ylabel('Y/mm')
        zlabel('Z/mm')
    else
        axes(handles.axes_ballmod);
        p1 = patch('Faces', P{n - 1,1}, 'Vertices', vo,'FaceColor','red','EdgeColor','none');
        daspect([0.2 0.2 0.18])
        view(-40,24)
        alpha(0.5)
        hold on
        [a,b] = size(Ball{n - 1,1});
        for j = 1:a
            sphere1(Ball{n - 1,1}(j,1),Ball{n - 1,1}(j,2),Ball{n - 1,1}(j,3),Ball{n - 1,1}(j,4));
        end
        xlabel('X/mm')
        ylabel('Y/mm')
        zlabel('Z/mm')
    end
end

function listbox_ballmod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_ballmod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ballmodexp.
function pushbutton_ballmodexp_Callback(hObject, eventdata, handles)
global Ball
[a,b] = size(Ball);
srcDir = uigetdir('select the output folder'); 

BB = Ball{1,1};
for p = 2:a
    BB = [BB;Ball{p,1}];
end

fid1 = fopen(['' srcDir '\PR.txt'],'wt');
fprintf(fid1,[repmat('%2.6f\t', 1, size(BB,2)), '\n'], BB');
fclose(fid1); 

for i = 1:a
    N = Ball{i,1};
    fid1 = fopen(['' srcDir '\PR',num2str(i),'.txt'],'wt');
    fprintf(fid1,[repmat('%2.6f\t', 1, size(N,2)), '\n'], N');
    fclose(fid1); 
end



function pushbutton_PSD_Callback(hObject, eventdata, handles)
global Ball PSD

[c,d] = size(Ball);
for i = 1:c
    DD{i,1} = Ball{i,1}(:,4).*2;
end

for j = 1:c + 1
    if j == 1
        D = DD{1,1};
        for p = 2:c
            D = [D;DD{p,1}];
        end
        D = sort(D);
        [a,b] = size(D);
    else
        [a,b] = size(DD{j - 1,1});
        if a == 1        
            PSD{j,1} = [];
            continue
        end
        D = sort(DD{j - 1,1});
    end
    V = pi.*D.^3/6;
    s = sum(V);
    F = V./s;
    L = zeros(a,2);
    for i = 1:a
        L(i,1) = D(i);
        L(i,2) = sum(F(1:i));
    end

    for i = 1:2
        x=1:a;x=x';y=L(:,i);x1=1:0.01:a;
        y1=interp1(x,y,x1,'linear');
        N(:,i) = y1;
    end

    [e,d] = size(N);
    k = 1;
    m = max(N(:,1)) - min(N(:,1));
    n = m/10;
    f = min(N(:,1)) + n;
    for i = 1:e
        if N(i,1) >= f
            k = k + 1;
            S(k,1) = f;
            S(k,2) = N(i,2);
            S(k,3) = f - n/2;
            f = f + n;
        end
        if k == 10
            break
        end
    end
    
    S(1,1) = min(N(:,1));S(1,3) = min(N(:,1));
    S(k + 1,1) = max(N(:,1));S(k + 1,2) = 1;S(k + 1,3) = max(N(:,1)) - n/2;
    S(k + 2,3) = max(N(:,1));
    
    for i = 2 : k + 1
        S(i,4) = S(i,2) - S(i-1,2);
    end
    PSD{j,1} = S;
    clearvars -except DD j PSD c  handles
end

str{1,1} = ['total pore'];

for i = 1:c
    str{i + 1,1} = [num2str(i)];
end

set(handles.listbox_PSD,'String',str);



function listbox_PSD_Callback(hObject, eventdata, handles)
global PSD

cla reset
sel = get(gcf,'selectiontype');               
if strcmp(sel,'open')                        
    n = get(hObject, 'value');             
    S = PSD{n,1};
    if isempty(S)
        h = msgbox('Psd of individual pore','hint');
        l = findobj(h);
        set(l(1,1),'Position',[862.2500 501.4167 150 55]);
        set(l(2,1),'FontSize',10);
        set(l(2,1),'Position',[55 6 40 17]);
        set(l(4,1),'FontSize',12);
    else
        x = S(1:11,1);
        y = S(1:11,2);
        x1 = min(x):(max(x) - min(x))/100:max(x);
        y1 = interp1(x,y,x1,'spline');
        
        x2 = S(:,3);
        y2 = S(:,4);
        x3 = min(x2):(max(x2) - min(x2))/100:max(x2);
        y3 = interp1(x2,y2,x3,'spline');
        
        axes(handles.axes_PSD);
        plot(x1,y1,'LineWidth',3,'Color','r')
        hold on
        plot(x3,y3,'LineWidth',3,'Color','b')
        xlabel('radius /mm')
        ylabel('percentage')
        legend('Cumlutive distribution curve','Relative distribution curve')
        axis tight
        set(handles.axes_PSD,'ytick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
        set(handles.axes_PSD,'yticklabel',{'0','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'})
    end
end

function listbox_PSD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_PSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton_PSDexp_Callback(hObject, eventdata, handles)
global PSD
[a,b] = size(PSD);
srcDir = uigetdir('select the output folder');  

for i = 1:a
    N = PSD{i,1};
    if i == 1
        fid1 = fopen(['' srcDir '\PSD.txt'],'wt');
    else
        fid1 = fopen(['' srcDir '\PSD',num2str(i - 1),'.txt'],'wt');
    end
    fprintf(fid1,[repmat('%2.6f\t', 1, size(N,2)), '\n'], N');
    fclose(fid1);
end

function listbox_fit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





