from django.conf.urls import url

from . import views

urlpatterns = [
    # base home pape
    url(r'^$', views.index, name='index'),
    url(r'^contact/$', views.contact, name='contact'),
    url(r'^methods/$', views.methods, name='methods'),
    url(r'^statistics/$', views.statistics, name='statistics'),
    url(r'^download/$', views.download, name = 'download'),

    # tRNA
    url(r'^trna/$', view=views.trna, name='trna'),
    # codon
    url(r'^codon/$', view=views.codon, name='codon'),
    # amino acid
    url(r'^aa/$', view=views.aa, name='aa'),
    # aa codon freq
    url(r'^freq/$', view=views.freq, name = 'freq'),

    # trna expression
    url(r'^trna/trna_expr_table/$', views.trna_expr_table, name='trna_expr_table'),

    # tumor vs. normal
    url(r'^trna/tm_comparison_table/$', views.tm_comparison_table, name='tm_comparison_table'),
    url(r'^trna/tm_comparison_table/png/(?P<png_name>.*)$', views.tm_comparison_table_png, name="tm_comparison_table_png"),

    # subtype
    url(r'^trna/diff_subtype_table/$', views.diff_subtype_table, name='diff_subtype_table'),
    url(r'^trna/diff_subtype_table/png/(?P<png_name>.*)$', views.diff_subtype_table_png, name="diff_subtype_table_png"),

    # survival
    url(r'^trna/survival_table/$', views.survival_table, name="survival_table"),
    url(r'^trna/survival_table/png/(?P<png_name>.*)$', views.survival_table_png, name="survival_table_png"),

    # freq
    url(r'^trna/freq_table/$', views.freq_table, name='freq_table'),
    url(r'^trna/freq_aa_table/$', views.freq_aa_table, name='freq_aa_table'),
    url(r'^trna/freq_codon_table/$', views.freq_codon_table, name='freq_codon_table'),
    url(r'^trna/filter_table/$', views.filter_table, name='filter_table'),


    # apis
    url(r'^api/summary$', views.api_summary, name='api_summary'),

    # subtype
    url(r'^api/subtype/(?P<dataset_id>TCGA-\w*)$', views.api_subtype, name='api_subtype'),

    # input autocompletion
    url(r'^api/list/(?P<module>trna|codon|aa|freq)/(?P<search>.*)$', views.api_trna_list, name='api_trna_list'),
    url(r'^api/check/(?P<module>trna|codon|aa|freq)/(?P<search>.*)$', views.api_trna, name='api_trna'),

    # trna expression
    url(r'^api/trna_expr/$', views.api_trna_expr, name='api_trna_expr'),

    # tumor normal comparison
    url(r'^api/tm_comparison/$', views.api_tm_comparison, name='api_tm_comparison'),

    # subtype
    url(r'^api/diff_subtype/$', views.api_diff_subtype, name="api_diff_subtype"),

    # survival
    url(r'^api/survival/$', views.api_survival, name="api_survival"),

    # freq aa and freq codon
    url(r'^api/freq/$', views.api_freq, name="api_freq"),
    url(r'^api/freq_aa/$', views.api_freq, name="api_freq"),
    url(r'^api/freq_codon/$', views.api_freq, name="api_freq"),

    # load codon
    url(r'^api/codon/$', views.api_codon, name="api_codon"),
    url(r'^api/filter/$', views.api_filter, name="api_filter"),
]