from  classroom_examples.piechart import piechart

labels = 'Frogs', 'Hogs', 'Dogs', 'Logs', 'Pogs'
sizes = [15, 30, 30, 10, 15]
colors = ['yellowgreen', 'gold', 'lightskyblue', 'lightcoral', 'y']
explode = (0, 0.1, 0, 0, 0.2)

piechart(sizes=sizes, labels=labels, colors=colors, explode=explode)
