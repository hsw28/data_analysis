#! /usr/bin/python

import sys
import gtk
import numpy as np

class WaveDemo: 

	def on_window1_delete_event(self, widget, data=None):
		gtk.main_quit()
		sys.exit(0)

	def on_quit_button_clicked(self, widget, data=None):
		gtk.main_quit()
		sys.exit(0)

	def on_time_field_focus_in_event(self, widget, data=None):
		print("time_field_focus")
		print(self)

	def on_play_button_toggled(self, widget, data=None):
		print(self)
		print("play_button_toggled")

	def on_field_button_toggled(self, widget, data=None):
		if(self.field_button.get_active()):		
			print("field toggled")

	def on_tetrode_button_toggled(self, widget, data=None):
		if(self.tetrode_button.get_active()):
			print("tetrode toggled")
			print("still printing")

	def on_test_test(self, widget, data=None):
		print("test test")

	def __init__(self):

		builder = gtk.Builder()
		builder.add_from_file("wave_gui.glade")

		self.window = builder.get_object("window1")
		self.freq_field = builder.get_object("freq_field")
		self.lambda_field = builder.get_object("lambda_field")
		self.theta_field = builder.get_object("theta_field")
		self.time_field = builder.get_object("time_field")
		self.comp_field = builder.get_object("compression_field")
		self.play_button = builder.get_object("play_button")
		self.field_button = builder.get_object("field_button")
		self.tetrode_button = builder.get_object("tetrode_button")
		self.print_count = 0

		builder.connect_signals(self)
		self.builder = builder;


	def on_param_changed(self, widget, data=None):
		print(self)
		self.gen_data()

	def gen_data(self):
		if(self.field_button.get_active()):
			x = np.linspace(0, 5, 50)
			y = np.linspace(-2, -7, 50)
		else:
			x = np.array([1.5, 2, 2.5, 3, 3.5, 4,  1.25, 1.75, 2.25, 2.75, 3.25, 3.75, 1.5, 2, 2.5, 3, 3.5, 4])
			y = np.array([-2.5, -3, -3.5, -4, -4.5, -5,  -2.75, -3.25, -3.75, -4.25, -4.75, -5.25,  -3.5, -4, -4.5, -5, -5.5, -6])
		
        	xm = x[:,np.newaxis]
        	ym = y[np.newaxis,:]
		z = np.zeros(xm.shape,dtype=complex)	 # I'll soon make x,y into complex Re(z) = x, Im(z) = y	
		proj_dist = np.zeros(xm.shape,dtype=float) # this will be a vector of projections of x,y onto the unit cycle
		m = np.zeros(xm.shape,dtype=float) # and these will finally be the wave height values

		#print(self.time_field)
		t = float(self.time_field.get_text())
		#print(self.freq_field)
		freq = float(self.freq_field.get_text())
		#print(self.theta_field)
		theta = float(self.theta_field.get_text())
		#print(self.lambda_field)
		lam = float(self.lambda_field.get_text())

		print(lam)
		print(theta)
		
		cycle_vec = lam * complex(np.cos(theta * np.pi /180), np.sin(theta * np.pi / 180)) # this vector represents one wave cycle, in the specified direction
		unit_vec_in_theta = cycle_vec / abs(cycle_vec)

		for n in np.arange(x.size):
			z[n] = complex(x[n],y[n])
			print(z[n])
			print([z[n].real,z[n].imag])
			print([cycle_vec.real,cycle_vec.imag])
			print(abs(cycle_vec))
			proj_dist[n] = np.dot([z[n].real,z[n].imag],[cycle_vec.real,cycle_vec.imag]) / abs(cycle_vec)
			m[n] = np.cos( (proj_dist[n] * 2 * np.pi / abs(cycle_vec)) + (t*freq*2*np.pi) )
		self.xm = xm
		self.ym = ym
		self.m = m
		print m

	def plot_data(app):
		print("plot data")
	

# Main function
if __name__ == "__main__" :
	wd = WaveDemo()
	wd.window.show()
	gtk.main()

print("Hello World!")
