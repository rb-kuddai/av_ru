# [AdvancedVision2](http://www.inf.ed.ac.uk/teaching/courses/av/)

Это задание выполнялось совместно с  [Todor Davchev](https://github.com/yadrimz/3D-Modelling-Kinect). 
Задача была в том, чтобы соединить вместе объемные снимки (range data) с Kinect, чтобы
востановить 3d объект (своеобразный клин), используя различные маркеры. 

Отчет находится в [Advanced_Vision_Assignment_2.pdf](https://github.com/rb-kuddai/av_ru/blob/master/Advanced_Vision_Assignment_2.pdf).
Главные части алгоритма с комментариями описаны в [main.m](https://github.com/yadrimz/3D-Modelling-Kinect/blob/master/main.m).
* Основой для вычитания фона служило PCA преобразование (т.к. там будет большинство точек в плоскости, а значит 2 первых PCA вектора (с наибольшими собственными значениями) опредяляют плоскость фона). 
* Основой для определения кластеров точек принадлежащим различным объектам был алгоритм кластерезации DBscan, которые в отличие от K-means позволяет захватывать кластеры произвольной формы.
* Соединение объемных изображений на основе сопостваления цветовых гистограмм.

Пример одного объемного снимка:

![range_data](https://github.com/rb-kuddai/av_ru/blob/master/images/plane_background_PCA.png)

Получившиеся объединеные точки объекта очищенные от лишнего:

![merged_cube](https://github.com/rb-kuddai/av_ru/blob/master/merged_cube.png)

И поверхности на их основе:

![planes](https://github.com/rb-kuddai/av_ru/blob/master/extracted_planes.png)

