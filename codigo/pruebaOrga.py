# import matplotlib.pyplot as plt
# import numpy as np

# t = np.arange(0.0, 5.0, 0.01)
# s = np.sin(2*np.pi*t)


# def lineal(m,x1,x2,b):
#   for i in range(x1,x2):
#       y=m*i+b

#   return y
# a = np.arange(0.0, 5.0, 0.01)
# b = lineal(1,0,5,0)
# plt.plot(t, s)


# plt.plot(1,b)

# plt.xlabel('Las X amigo')
# plt.ylabel('Las Y amigo')
# plt.title('Grafican2')
# # plt.grid(True)
# plt.savefig("test.png")
# plt.show()



#def graphico(formula, x_range, formula2, x_range2):  
    # x = np.array(x_range)  
    # y = eval(formula)
    # w = np.array(x_range2)
    # z = eval(formula2)
    # a=5
    # hola.plot(3,a,'bo')
    # #plt.plot(x, y)  
    # a=30
    # plt.plot(2,2,'ro')
    # plt.plot(1,10,'go')
   # plt.show()
   # plt.plot(w, z)
# for i in range(1,10):
#       hola.plot(i,i,'go')
# plt.xlabel('Las X amigo')
# plt.ylabel('Las Y amigo')
# plt.title('Grafican2')
# plt.grid(True)
# plt.savefig("test.png")
# plt.show()


#graphico('2*x',range(0,5),'3*x',range(0,5))

#!/usr/bin/python



# with open("GG.txt") as f:
#     data = f.read()

# data = data.split('\n')

# x = [row.split(' ')[0] for row in data]
# y = [row.split(' ')[1] for row in data]

# fig = plt.figure()

# ax1 = fig.add_subplot(111)

# ax1.set_title("Plot title...")    
# ax1.set_xlabel('your x label..')
# ax1.set_ylabel('your y label...')

# ax1.plot(x,y, c='r', label='the data')

# leg = ax1.legend()

# plt.show()
import math
import numpy as np
import matplotlib.pyplot as plt
import pylab

arr = np.genfromtxt("SEPIA_C_O0")
c0_x = [row[0] for row in arr]
c0_y = [row[1] for row in arr]
err0 = [row[2] for row in arr]

arr = np.genfromtxt("SEPIA_C_O1")
c1_x = [row[0] for row in arr]
c1_y = [row[1] for row in arr]
err1 = [row[2] for row in arr]

arr = np.genfromtxt("SEPIA_C_O2")
c2_x = [row[0] for row in arr]
c2_y = [row[1] for row in arr]
err2 = [row[2] for row in arr]


arro3 = np.genfromtxt("SEPIA_C_O3")
c3_x = [row[0] for row in arro3]
c3_y = [row[1] for row in arro3]
err3 = [row[2] for row in arro3]

arrr = np.genfromtxt("SEPIA_ASM")
asm_x = [row[0] for row in arrr]
asm_y = [row[1] for row in arrr]
errASM = [row[2] for row in arrr]

# a = np.arange(2048*2048)
# b = 600*a


fig = plt.figure()
fig.patch.set_facecolor('white')

plt.errorbar(c0_x, c0_y, err0)
plt.errorbar(c3_x, c3_y, err1)
plt.errorbar(c3_x, c3_y, err2)
plt.errorbar(c3_x, c3_y, err3)
plt.errorbar(asm_x, asm_y, errASM)


ax1 = fig.add_subplot(111)
pylab.plot(c0_x,c0_y,c='r', label= 'C - O0')
pylab.plot(c0_x,c1_y,c='g', label= 'C - O1')
pylab.plot(c0_x,c2_y,c='b', label= 'C - O2')
pylab.plot(c3_x,c3_y,c='c', label= 'C - O3')
pylab.plot(asm_x,asm_y,c='m', label = 'ASM - SIMD')

# pylab.plot((a),(b), c='r', label ='f(X)=1024x')
# plt.errorbar(w, z, np.std(desvio))
ax1.set_title("SEPIA")
ax1.set_xlabel('Cantidad de pixeles de la imagen')
ax1.set_ylabel('Cantidad de ciclos de Clock')
ax1.set_yscale('log', basey=2)
ax1.set_xscale('log', basex=2)


#ax1.plot(np.log2(x),np.log2(y), c='r', label='EL CHACHO ARRIBAS')
# pylab.plot((x),(y), c='r', label='ASM')
# pylab.plot(w,z, c='b',label='C')
leg = ax1.legend()

leg = plt.legend( loc = 'upper left')

plt.show()