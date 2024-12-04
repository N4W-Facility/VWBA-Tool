function G = remove_cycles_dfsearch(G)
    % remove_cycles_dfsearch: Elimina ciclos de un grafo dirigido usando dfsearch
    % Entrada:
    %   - G: Grafo dirigido (digraph)
    % Salida:
    %   - G: Grafo dirigido acíclico (DAG)

    while true
        % Detectar la primera arista responsable de un ciclo
        cycle_edge = detect_cycle_edge(G);

        % Si no se detectan ciclos, terminamos
        if isempty(cycle_edge)
            disp('El grafo es ahora acíclico.');
            break;
        end

        % Mostrar la arista detectada como responsable del ciclo
        disp(['Eliminando la arista responsable del ciclo: ', ...
              num2str(cycle_edge(1)), ' -> ', num2str(cycle_edge(2))]);

        % Eliminar la arista responsable del ciclo
        G = rmedge(G, cycle_edge(1), cycle_edge(2));
    end
end

function cycle_edge = detect_cycle_edge(G)
    % detect_cycle_edge: Detecta la primera arista que causa un ciclo en el grafo
    % Entrada:
    %   - G: Grafo dirigido (digraph)
    % Salida:
    %   - cycle_edge: Una arista responsable de un ciclo ([source, target]).
    %                 Vacío si no se detectan ciclos.

    % Inicialización
    cycle_edge = [];

    % Realizar búsqueda en profundidad
    events = dfsearch(G, 1, 'allevents');

    % Buscar el primer evento 'edgetodiscovered' que indica un ciclo
    idx = find(strcmp(events.Event, 'edgetodiscovered'), 1);

    if ~isempty(idx)
        % Capturar la arista responsable del ciclo
        cycle_edge = events.Edge(idx, :); % Extraer los nodos origen y destino
    end
end
