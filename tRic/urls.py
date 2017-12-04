from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^contact/$', views.contact, name='contact'),
    url(r'^methods/$', views.methods, name='methods'),
    url(r'^statistics/$', views.statistics, name='statistics'),
]