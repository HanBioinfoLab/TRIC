from django.conf.urls import url

from . import views

urlpatterns = [
    # base home pape
    url(r'^$', views.index, name='index'),
    url(r'^contact/$', views.contact, name='contact'),
    url(r'^methods/$', views.methods, name='methods'),
    url(r'^statistics/$', views.statistics, name='statistics'),

    # tRNA
    url(r'^trna/$', view=views.trna, name='trna'),


    # apis
    url(r'^api/summary$', views.api_summary, name='api_summary'),

    # subtype
    url(r'^api/subtype/(?P<dataset_id>TCGA-\w*)$', views.api_subtype, name='api_subtype'),

    # input autocompletion
    url(r'^api/trna_list/(?P<search>.*)$', views.api_trna_list, name='api_trna_list'),
    url(r'^api/trna/(?P<search>.*)$', views.api_trna, name='api_trna'),

]