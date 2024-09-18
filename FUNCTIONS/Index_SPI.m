function [Date, SPI, DroughtClass] = Index_SPI(Date, Data, varargin)
% -------------------------------------------------------------------------
% Matlab - R2023b 
% -------------------------------------------------------------------------
%                           Información Basica
%--------------------------------------------------------------------------
% Autor         : Jonathan Nogales Pimentel
% Email         : jonathannogales02@gmail.com
% Fecha         : abril-2024
%
%--------------------------------------------------------------------------
% Este programa es de uso libre: Usted puede redistribuirlo y/o modificarlo 
% bajo los términos de la licencia publica general GNU. El autor no se hace 
% responsable de los usos que pueda tener. Para mayor información revisar 
% http://www.gnu.org/licenses/
%
% -------------------------------------------------------------------------
% Descripción del Codigo
% -------------------------------------------------------------------------
% Esta función calcula el SPI utilizando las series de precipitación.
% 
% -------------------------------------------------------------------------
% Input Data
% -------------------------------------------------------------------------
% obj
%   .Data   [mm]        Precipitación Mensual
%   .Date   [datetime]  Fecha en meses
%
% -------------------------------------------------------------------------
% Output Data
% -------------------------------------------------------------------------
% SPI - Inidice estandarizado de precipitación

% -------------------------------------------------------------------------
% Validación parámetros de entrada opcionales
% -------------------------------------------------------------------------
% Reglas de verificación
ip = inputParser;
% Indicador SPI o SDI
List_Index = {'SPI','SDI','RDI'};
addParameter(ip,'Index',1,@(x) any(validatestring(x,List_Index)))
% Valor de la ventana temporal de análisis [1, 2, 3, 6 12]
addParameter(ip,'SizeStep',1,@double)

% Check de datos opcionales
parse(ip,varargin{:})
% Valor de la ventana temporal de análisis
SizeStep    = ip.Results.SizeStep;
StatusPlot = false;

% Selección de estacional
switch SizeStep
    case 1
        nseas = 12;
    case 2
        nseas = 6;
    case 3
        nseas = 4;
    case 6
        nseas = 2;
    case 12
        nseas = 1;
end

List_NameIndex = {'Standardized Precipitation Index (SPI)',...
                  'Streamflow Drought Index (SDI)',...
                  'Streamflow Drought Index (SDI)'};
if ischar(ip.Results.Index)
    [~,Posi]    = ismember(ip.Results.Index, List_Index);
    Index       = List_Index{Posi};
    NameIndex   = List_NameIndex{Posi};
else
    Index       = List_Index{ip.Results.Index};
    NameIndex   = List_NameIndex{ip.Results.Index};
end

% Agregar mensual
y = year(Date);
m = month(Date);
k = 1;
Dn = zeros(numel(unique(y))*12,1);
for i = 1:numel(unique(y))
    for j = 1:12
        Dn(k,1) = sum(Data((m==j)&(y == y(i))),'omitnan');
        k = k + 1;
    end
end
Data = Dn;
Date = (datetime(y(1),1,1):calmonths(1):datetime(y(end),12,1))';

% -------------------------------------------------------------------------
% Almacenadores de compilados
% -------------------------------------------------------------------------
Total_SPI       = Data*NaN;
Total_Class     = Data*NaN;
BestPDF         = cell(nseas,size(Data,2));

PoPo = 1;
for ii = 1:length(PoPo)
    try
        % -----------------------------------------------------------------
        % Selección de periodo con datos para la estación ii
        % -----------------------------------------------------------------
        id          = find( ~isnan(Data(:,PoPo(ii))) );   
        % Datos
        RawData     = Data(id(1):id(end),PoPo(ii));
        % Fechas
        RawDate     = Date(id(1):id(end));
        
        % -----------------------------------------------------------------
        % Agregar datos a la ventana temporal indicada
        % -----------------------------------------------------------------
        % Meses
        M       = month(RawDate);
        % Date1   = [(1:M(1)-1)'; M; (M(end)+1:12)'];
        Data    = [(1:M(1)-1)'*NaN; RawData; (M(end)+1:12)'*NaN];
        % Acumular datos
        if SizeStep ~= 1
            Data    = sum(reshape(Data,SizeStep,[]),'omitnan')';
        end
        % Fechas nuevas
        Date    = datetime(year(RawDate(1)),1,1):calmonths(SizeStep):datetime(year(RawDate(end)),12,1);
        % filtrar NaN
        id      = find(~isnan(Data));
        Data    = Data(id(1):id(end));
        Date    = Date(id(1):id(end))';

        % -----------------------------------------------------------------
        % Cálculo del SPI
        % -----------------------------------------------------------------
        % SPI
        % XS = (Data - mean(Data,'omitnan'))./std(Data,'omitnan');
        SPI     = Data*NaN; 
        rng(1,"twister");
        Data    = Data + rand(size(Data))*0.2;
        % Estimación de distribución teoría con mejor ajuste pdf
        % NamePDF     = 'Normal';
        % test_cdf    = fitdist(Data,NamePDF);
        for is = 1:nseas
            % Selección de datos de acuerdo con la ventana temporal
            tind        = is:nseas:length(Data);
            Xn          = Data(tind);
            % Encontrar datos que son cero
            [zeroa]     = find(Xn==0);
            % Selección de datos que no son ceros
            Xn_nozero   = Xn; Xn_nozero(zeroa)=[];
            % Estimación de q para correcicón
            q           = length(zeroa)/length(Xn);
            % Estimación de distribución teoría con mejor ajuste pdf
            NamePDF     = Fit_PDF(Xn_nozero);
            test_cdf    = fitdist(Xn_nozero,NamePDF);
            % Evalua los valores con la mejor función de probabildiad
            BestCDF     = q+(1-q)*cdf(test_cdf, Xn);
            % Se normalizan los datos a una función normar
            SPI(tind)   = norminv(BestCDF);
            % guardar mejor pdf
            BestPDF{is,ii} = NamePDF;
        end

        % Guardar compilado
        Total_SPI(id(1):id(end),PoPo(ii)) = SPI;
    
        % -----------------------------------------------------------------
        % Clasificación de sequias
        % -----------------------------------------------------------------
        % La clasificación se realiza de acuerdo con los rangos presentados
        % en la Tabla 1. del paper: https://doi.org/10.3390/w15020255
        %________________________________________________
        % ID | Clasifiación      |        Rango         |
        % 1  | Período Húmedo    | SPI > 0              |
        % 2  | Sequía Leve       | 0 > SPI >= -0.99     |
        % 3  | Sequía Moderada   | -0.99 > SPI >= -1.49 |
        % 4  | Sequía Severa     | -1.49 > SPI >= -1.99 |
        % 5  | Sequía Extrema    | -2.0 > SPI           |
        %-----------------------------------------------|
    
        % Clasificación
        DroughtClass = zeros(size(Data));
        % Período Húmedo    | SPI > 0
        DroughtClass(SPI >= 0)                      = 1;
        % Sequía Leve       | 0 > SPI >= -0.99}
        DroughtClass((0 > SPI)&(SPI >= -0.99))      = 2;
        % Sequía Moderada   | -0.99 > SPI >= -1.49
        DroughtClass((-0.99 > SPI)&(SPI >= -1.49))  = 3;
        % Sequía Severa     | -1.49 > SPI >= -1.99
        DroughtClass((-1.49 > SPI)&(SPI >= -1.99))  = 4;
        % Sequía Extrema    | -2.0 > SPI
        DroughtClass(SPI < -1.99)                   = 5;
    
        % Guardar compilado
        Total_Class(id(1):id(end),PoPo(ii)) = DroughtClass;
    catch
    end
end
end


function [NamePDF,Error,ParamBestPDF] = Fit_PDF(Data)
% -------------------------------------------------------------------------
% Matlab - R2023b 
% -------------------------------------------------------------------------
%                           Información Basica
%--------------------------------------------------------------------------
% Autor         : Jonathan Nogales Pimentel
% Email         : jonathannogales02@gmail.com
% Fecha         : abril-2024
%
%--------------------------------------------------------------------------
% Este programa es de uso libre: Usted puede redistribuirlo y/o modificarlo 
% bajo los términos de la licencia publica general GNU. El autor no se hace 
% responsable de los usos que pueda tener. Para mayor información revisar 
% http://www.gnu.org/licenses/
%
% -------------------------------------------------------------------------
% Descripción del Código
% -------------------------------------------------------------------------
% Este código ajusta un conjunto de datos a la mejor distribución de
% probabilidad de un conjunto de 12 funciones, a saber:
%   -> Nakagami
%   -> G-ExtremeValue
%   -> Normal
%   -> Lognormal
%   -> Gamma
%   -> Gumbel
%   -> Weibull
%   -> Exponential
%   -> tLocationScale
%   -> GeneralizedPareto
%   -> Logistic
%   -> LogLogistic
% 
% -------------------------------------------------------------------------
% Input Data
% -------------------------------------------------------------------------
% Data : Vector de datos 
%
% -------------------------------------------------------------------------
% Output Data
% -------------------------------------------------------------------------
% NamePDF       : Nombre de Matlab de la pdf que mejor se ajusto a los datos
% Error         : Error de ajuste de la mejor pdf
% ParamBestPDF  : Parámetros de la pdf que mejor se ajusto a los datos
% Fig           : Figura con los ajustes de todas las pdf evaluadas

% -------------------------------------------------------------------------
% Pdf a evaluar
% -------------------------------------------------------------------------
CDF = { 'Nakagami','GeneralizedExtremeValue',...
        'Normal','Lognormal','Gamma', 'ExtremeValue', 'Weibull',...
        'Exponential', 'tLocationScale','GeneralizedPareto',...
        'Logistic','LogLogistic'};

NameP = {   'Nakagami','G-ExtremeValue',...
            'Normal','Lognormal','Gamma', 'Gumbel', 'Weibull',...
            'Exponential', 'tLocationScale','GeneralizedPareto',...
            'Logistic','LogLogistic'};

% -------------------------------------------------------------------------
% Llenado de datos NaN con el valor promedio
% -------------------------------------------------------------------------
Data(isnan(Data)) = mean(Data(~isnan(Data)));

% -------------------------------------------------------------------------
% Estimación de distribucion empirica 
% -------------------------------------------------------------------------
[Fe,x_values] = ecdf(Data);

% -------------------------------------------------------------------------
% Error de ajuste inicial
% -------------------------------------------------------------------------
Error = 1E12;

for io = 1:length(CDF)
    % Parametros de la pdf evaluada
    test_cdf1    = fitdist(Data,CDF{io});

    % Prueba de Kolmog�rov-Smirnov
    [h, p]      = kstest(Data,'CDF',test_cdf1,'Alpha',0.05);
    
    % Distribucion teorica con la pdf evaluada
    Ft          = cdf(test_cdf1, x_values);
    
    % Error Cuadratico Medio del ajuste 
    RMSE        = sqrt(mean((Fe - Ft).^2));

    % Mejor ajuste 
    if RMSE < Error 
        ParamBestPDF    = test_cdf1; 
        Error           = RMSE;
        NamePDF         = CDF{io};
    end

end

end
