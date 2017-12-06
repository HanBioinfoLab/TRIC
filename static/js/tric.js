/*
tRic main js
Depends on JQuery v1.12.4, jquer-ui v1.12.1, dataTable v.1.10.1
Author: C.J. Liu
Contact: chunjie-sam-liu@foxmail.com
 */

var tric=(function(){
    'use strict';
    var PRODUCT = "tRic namespace",
    VERSION = "0.1",
    ANALYSIS_TIMEOUT = 90000,
    QUERY_MAX_LENGTH = 50000,
    VIEW_STALE = 'ok',
    UNDEFINED;



    // registered analysis number
    function getNumAnalyses(){
        var num = 0;
        for (var analysis in ARGUMENTS.analyses) {
            if (ARGUMENTS.analyses.hasOwnProperty(analysis)) {
                if (ARGUMENTS.analyses[analysis] === true) {
                    num += 1;
                }
            }
        }
        return num;
    }
    // --------------------------------------------------------------

    // for analysis
    function inputQueryAutoComplete(elem){
        $(elem).autocomplete({
            autoFocus: true,
            source: function(request, response){
                var url = '/SNORic/api/gene_symbol_list/' + request.term.trim();
                $.getJSON(
                    url,
                    function(data){
                        response($.map(data, function(item){return item.gene_symbol}))
                    }
                );
            },
            select: function(envent, ui){
                showSuccess(this);
            }
        })
    }

    function analysis_gene_symbol_input_keyup_handler(){
        var $gene_input = $("#gene-input");
        $gene_input.keyup(function () {
            clearValidationStyles(this);
            var gene_symbol = this.value.trim();
            if (gene_symbol !== '') {
                checkAnnotationInput(gene_symbol.toLowerCase(), this, '/SNORic/api/gene_symbol/');
            }
        });
    }

    function validateQuery(){
        var selected_analysis = [];
        var gene_based_analysis = ['corr_cnv', 'corr_geneexpr', 'corr_appr', 'methylation'];
        $('input[type="checkbox"][name="selected_analysis"]:checked').each(function(){
            selected_analysis.push(this.value);
        });
        for(var i = 0, len = selected_analysis.length; i<len; i++){
            if(gene_based_analysis.indexOf(selected_analysis[i])!= -1){
                if(!$("#gene-input-div").hasClass('has-success')){
                    if($("#gene-input").val() === ''){
                        alert("Please input gene symbol.");
                    }else{
                        alert("Invalid gene symbol.");
                    }
                    return false
                }
            }
        }
        if(selected_analysis.length === 0){
            alert("No analysis has been selected.");
            return false
        }
        return true;
    }

    function queryAnalysis(){
        gNCompletedAnalyses = {};
        var dataset_id = $("#select_dataset").val(),
            query_gene = $("#gene-input").val();
        ARGUMENTS = {
            dataset_ids: [dataset_id],
            analyses: {
                snorna_expr: false,
                survival: false,
                diff_subtype: false,
                corr_geneexpr: false,
                corr_splicing: true,
                corr_rppa: false,
                corr_cnv: false,
                methylation: false
            },
            query_gene: query_gene
        };

        $("input[name='selected_analysis']:checked").each(
            function(){
                var analysis = $(this).val();
                ARGUMENTS.analyses[analysis] = true;
            }
        );

        $("#progressbar").show();
        hideAnalysesTabs();
        showAllAnalysesTabs();
        setTimeout(
            function(){
                updateLoadingProgress()
            },
            1000
        );
        for(var analysis in ARGUMENTS.analyses){
            if(ARGUMENTS.analyses.hasOwnProperty(analysis)){
                if(ARGUMENTS.analyses[analysis]){
                    getAnalysisTable(analysis, dataset_id, query_gene)
                }
            }
        }
    }

    function getAnalysisTable(analysis, dataset_id, query_gene){
        switch (analysis){
            case 'corr_cnv':
                getList(
                    'corr_cnv_bygene',
                    'corr_cnv_bygene',
                    {
                        dataset_ids: dataset_id,
                        query_gene: query_gene
                    },
                    buildLoadDataTableCallback({
                        'analysis': analysis,
                        'table_tmpl_name': 'corr_cnv_bygene_table'
                    })
                );
                break;
            case "snorna_expr":
                getList(
                    "snorna_expr_bygene",
                    "snorna_expr_bygene",
                    {
                        dataset_ids: dataset_id,
                        query_gene: query_gene
                    },
                    buildLoadDataTableCallback(
                        {
                            "analysis": analysis,
                            "table_tmpl_name": "snorna_expr_bygene_table"
                        }
                    )
                );
                break;
            case "diff_subtype":
                getList(
                    "diff_subtype_bygene",
                    "diff_subtype_bygene",
                    {
                        dataset_ids: dataset_id,
                        query_gene: query_gene
                    },
                    buildLoadDataTableCallback({
                        analysis: analysis,
                        table_tmpl_name: "diff_subtype_bygene_table"
                    })
                );
                break;
            case "survival":
                getList(
                    "survival_bygene",
                    "survival_bygene",
                    {
                        dataset_ids: dataset_id,
                        query_gene: query_gene
                    },
                    buildLoadDataTableCallback({
                        analysis: analysis,
                        table_tmpl_name: "survival_bygene_table"
                    })
                );
                break;
            case "corr_geneexpr":
                getList(
                    "corr_geneexpr_bygene",
                    "corr_geneexpr_bygene",
                    {
                        dataset_ids: dataset_id,
                        query_gene: query_gene
                    },
                    buildLoadDataTableCallback({
                        analysis: analysis,
                        table_tmpl_name: "corr_geneexpr_bygene_table"
                    })
                );
                break;
            case "corr_splicing":
                getList(
                    "corr_splicing_bygene",
                    "corr_splicing_bygene",
                    {
                        dataset_ids: dataset_id,
                        query_gene: query_gene
                    },
                    buildLoadDataTableCallback({
                        analysis: analysis,
                        table_tmpl_name: "corr_splicing_bygene_table"
                    })
                );
                break;
            case "corr_rppa":
                getList(
                    "corr_rppa_bygene",
                    "corr_rppa_bygene",
                    {
                        dataset_ids: dataset_id,
                        query_gene: query_gene
                    },
                    buildLoadDataTableCallback({
                        analysis: analysis,
                        table_tmpl_name: "corr_rppa_bygene_table"
                    })
                );
                break;
            case "corr_cnv":
                getList(
                    "corr_cnv_bygene",
                    "corr_cnv_bygene",
                    {
                        dataset_ids: dataset_id,
                        query_gene: query_gene
                    },
                    buildLoadDataTableCallback({
                        analysis: analysis,
                        table_tmpl_name: "corr_cnv_bygene_table"
                    })
                );
                break;
            case "methylation":
                getList(
                    "methylation_bygene",
                    "methylation_bygene",
                    {
                        dataset_ids: dataset_id,
                        query_gene: query_gene
                    },
                    buildLoadDataTableCallback({
                        analysis: analysis,
                        table_tmpl_name: "methylation_bygene_table"
                    })
                );
                break;
        }
    }


    // --------------------------------------------------------------
    // for tRic program
    // --------------------------------------------------------------
    //   Module Variables
    var DEBUG = false,
        OTABLES = {},
        TABLEDATA = {},
        JOBID = '',
        ARGUMENTS = {},
        ALLOW_STALE = true;

    // reserved variable
    var TIMEOUT_DIALOG = null;
    var IS_JOB_RUNNING = false;
    var TIMEOUT_STOP = false;
    var IS_ANALYSIS_TIMEOUT = false;
    var analysisTimeout = {};
    var JOB_RUNNING_DIALOG = null;
    var gNCompletedAnalyses = {};
    var JOB = {};
    var gAnalysisLabel = {
        diff_subtype: 'Diff. subtype',
        trna_expr: 'tRNA expr.',
        tm_comparison: 'Tumor vs. Normal',
        survival: 'Survival'
    };
    var gAnalysisTabsOrder = {
        trna_expr: 0,
        tm_comparison: 1,
        diff_subtype: 2,
        survival: 3
    };
    var gAnalysisTabsClass = {
        trna_expr: 'rnaexpr',
        tm_comparison: 'rnaexpr',
        diff_subtype:  'clinical',
        survival:      'clinical'
    };
    var default_datatable_settings = {
            processing: true,
            stateSave: true,
            language: {
                decimal: ",",
                emptyTable: "No significant entries in analysis or in this cancer type!"
            }
        },
        survival_datatable_settings = {
            columns: [
                {data: "dataset_id"},
                {data: "snorna"},
                {data: "p\\.value"},
                {
                    class: 'details-control',
                    orderable: false,
                    data: null,
                    defaultContent: ''
                }
            ]
        },
        diff_subtype_datatable_settings = {
            columns: [
                {data: "dataset_id"},
                {data: "snorna"},
                {data: "subtype"},
                {data: "p\\.value"},
                {
                    class: 'details-control',
                    orderable: false,
                    data: null,
                    defaultContent: ''
                }
            ]
        },
        rnaexpr_datatable_settings = {
            order: [[3, 'desc']],
            columns: [
                {data: "dataset_id", width: "30%"},
                {data: "trna", width: "30%"},
                {data: "sample_id", width: "30%"},
                {data: "expr", width: "10%"}
            ]
        },
        corr_rppa_datatable_settings = {
            columns: [
                {data: "dataset_id"},
                {data: "snorna"},
                {data: "protein"},
                {data: "spearman_corr"},
                {data: "p_value"},
                {
                    class: 'details-control',
                    orderable: false,
                    data: null,
                    defaultContent: ''
                }
            ]
        },
        corr_cnv_datatable_settings = {
            columns: [
                {data: "dataset_id"},
                {data: "snorna"},
                {data: "estimate"},
                {data: "p\\.value"},
                {
                    class: 'details-control',
                    orderable: false,
                    data: null,
                    defaultContent: ''
                }
            ]
        },
        methylation_datatable_settings = {
            order: [[3, "desc"]],
            columns: [
                {data: "dataset_id"},
                {data: "snorna"},
                {data: "meth_id"},
                {data: "estimate"},
                {data: "p\\.value"},
                {
                    class: 'details-control',
                    orderable: false,
                    data: null,
                    defaultContent: ''
                    }
            ]
        },
        snorna_expr_bygene_datatable_settings = {
        order: [[2, 'desc']],
            columns: [
                {data: "dataset_id"},
                {data: "snorna"},
                {data: "mean_expression"}
            ]
        };
    var analysis_datatable_settings = {
            'trna_expr': rnaexpr_datatable_settings,
            'survival': survival_datatable_settings,
            'diff_subtype': diff_subtype_datatable_settings
        };

    // Basic init
    // data set summary
    function load_dataset(){
        $('#dataset_summary').DataTable({
            "pageLength": 50,
            'processing': true,
            'ajax': '/tRic/api/summary',
            'order': [[5, 'desc']],
            stateSave: true,
            "language": {
                "decimal": ","
            },
            'columns': [
                {"data": "fields.dataset_description"},
                {"data": "fields.normal_n"},
                {"data": "fields.tumor_n"},
                {"data": "fields.average_mappable_reads"},
                {"data": "fields.snorna_n"},
                {"data": "fields.snorna_rpkm_n"}
            ]
        });
    }

    // reset query
    function reset(){
        $("#reset_basic").on("click", function(event){
            $("#select_dataset").val("TCGA-ACC").change();
            $("#select_subtype").val("all");
            $("#snorna").val("tRNA-Ala-AGC-1-1");
            $("input[name='selected_analysis']").prop("checked", true);
        });
        $("#reset_analysis").on("click", function(event){
            $("#select_dataset").val("TCGA-ACC").change();
            $("#gene-input").val("PTEN");
            $("input[name='selected_analysis']").prop("checked", true);
        });
    }

    // general javascript effect
    function general_effect(){
        $('input[type=text]').on(
            'click',
            function(){
                return $(this).select()
            }
        );
        $('.selectpicker').selectpicker({
            size: 4
        });
    }

    // select dataset and subtype
    function load_subtype() {
        $("#select_dataset").on('change', function () {
            var dataset_id = $(this).val();
            var url = '/tRic/api/subtype/' + dataset_id;
            $('#select_subtype').empty();
            // select subtype
            $.getJSON(
                url,
                function (data) {
                    var optgroup = {};
                    if (data.length < 1) {
                        $('#select_subtype').append("<option value=0>No subtype data</option>");
                        $("#select_analysis_diff_subtype")
                            .prop('checked', false)
                            .prop("disabled", true)
                            .closest("div")
                            .removeClass("disabled")
                            .addClass("disabled");
                    }
                    else {
                        $("#select_analysis_diff_subtype")
                            .prop('checked', true)
                            .prop("disabled", false)
                            .closest("div")
                            .removeClass("disabled");

                        $('#select_subtype').append("<option value='all'>All</option>");

                        data.forEach(function (ele) {
                            (optgroup[ele.subtype] = optgroup[ele.subtype] || []).push(ele.stage)
                        });
                        for (var subtype in optgroup) {
                            var te = $('<optgroup label="' + subtype + '"></optgroup>')
                                .appendTo($('#select_subtype'));
                            optgroup[subtype].forEach(function (stage) {
                                te.append("<option value='" + stage + "'>" + stage + "</option>");
                            });
                        }
                    }
                }
            );
        });
    }

    // --------------------------------------------------------------

    // tabs toggle
    function hideAnalysesTabs(){
        $("#analyses").hide();
        $(".analysis_tab").hide();
        $("#tabs ul").empty();
        $(".analysis_div").empty();
        $("#tabs").tabs();
    }

    function showAllAnalysesTabs() {
        $("#analyses").show();
        for (var analysis in ARGUMENTS.analyses) {
            if (ARGUMENTS.analyses.hasOwnProperty(analysis)) {
                if (ARGUMENTS.analyses[analysis]) {
                    var li_html = '<li class="analysis_tab analysis_'
                        + gAnalysisTabsClass[analysis]
                        + '" id="tab_'
                        + analysis
                        + '_li"><a href="#tab_'
                        + analysis
                        + '">'
                        + gAnalysisLabel[analysis]
                        + '</a></li>';
                    var current_tab_order_idx = gAnalysisTabsOrder[analysis];
                    var is_tab_added = false;
                    $("#tabs .analysis_tab").each(function (idx) {
                        var tab_analysis_tmp = $(this)
                            .attr('id')
                            .replace(/^tab_/, '')
                            .replace('/_li$', '');
                        var tab_order_idx = gAnalysisTabsOrder[tab_analysis_tmp];
                        if (current_tab_order_idx < tab_order_idx) {
                            $("#tabs ul li:qe(" + idx + ")").before($(li_html));
                            $("#tabs").tabs("refresh").tabs("option", "active", 0);
                            is_tab_added = true;
                            return false;
                        }
                        return true;
                    });
                    if (!is_tab_added) {
                        $("#tabs ul").append(li_html);
                        $("#tabs").tabs("refresh").tabs("option", "active", 0);
                    }
                }
            }
        }
        $("#tabs").tabs("disable");
    }

    // progress percentage
    function updateLoadingProgress(){
        var numAnalyses = getNumAnalyses();
        var numFinished = 0;
        for (var analysis in gNCompletedAnalyses) {
            if (gNCompletedAnalyses.hasOwnProperty(analysis)) {
                numFinished++;
            }
        }
        var percent_finished = 100 * numFinished / numAnalyses,
            progressbar = $("#progressbar");
        if (percent_finished > 0) {
            progressbar.progressbar("value", percent_finished);
        } else if (numFinished === 0) {
            progressbar.progressbar("value", false);
        }
        if (numFinished !== numAnalyses) {
            setTimeout(function(){
                updateLoadingProgress();
            }, 1000);
        }
    }

    // post data
    function getKeys(analysis) {
        var genes;
        var dataset_ids = ARGUMENTS.dataset_ids;
        var subtype_id = ARGUMENTS.subtype_id;
        if (JOB.is_preprocessed) {
            genes = ARGUMENTS.trna;
        }
        var keys = {
            analysis: analysis,
            dataset_ids : dataset_ids[0],
            genes: genes[0],
            subtype_id:subtype_id
        };
        return keys;
    }

    // tab check
    function enableAnalysesTab(analysis) {
        $("#tabs").tabs("enable", "#tab_" + analysis);
    }

    function buildLoadDataTableCallback(obj){
        console.log(obj);
        return function(error, data){
            var analysis = obj['analysis'];
            var table_id = obj['table_tmpl_name'] || analysis + '_table';
            var tmpl_id = 'tab_' + analysis, table_tmpl = '/tRic/trna/' + table_id;
            console.log({table_tmpl:table_tmpl});
            console.log({tmpl_id:tmpl_id});
            console.log({table_id:table_id});
            $("#"+tmpl_id).load(table_tmpl, function(){
                if(error){
                    alert("Error loading table:\n","\t", error);
                    return;
                }

                // jQuery is abso-fucking-lutely amazing!
                // add dataset_id and query trna to the data.
                jQuery.each(data, function(){
                    this.dataset_id = obj['dataset_ids'];
                    this.trna = obj['genes'];
                });

                TABLEDATA[table_id] = data;
                var analysis_datatable_setting = {};
                analysis_datatable_setting = analysis_datatable_settings[analysis];
                var dataTableSettings = $.extend(
                    {'data': data},
                    default_datatable_settings,
                    analysis_datatable_setting);
                if(analysis == "tm_comparison"){
                    var img_path = '/SNORic/basic/tm_comparison_table/png/' + data.png_name;
                    var img = '<img src="' +
                    img_path +
                    '" style="width:80%;height:80%" onerror="this.src=\'/SNORic/static/image/error.svg\'">';
                    // console.log(img);
                    $("#tm_comparison_table_png").empty().append(img);
                }
                else {OTABLES[table_id] = $('#'+table_id).DataTable(dataTableSettings);}
                enableAnalysesTab(analysis);
                gNCompletedAnalyses[analysis] = true;
            });
        };
    }

     // get data from mysql
    function getList(analysis, view, options, callback){
        var url = '/tRic/api/'+ analysis;
        $.getJSON(url, options)
            .done(function(data){
                callback(null, data);
            })
            .fail(function(jqxhr, status, error){
                callback(error,null);
                var err = status + ", " + error;
                console.log(err);
        });
    }

    function getAnalysisData(analysis) {
        getList(analysis,
                'preprocessed_analyses',
                getKeys(analysis),
                buildLoadDataTableCallback(getKeys(analysis)));
    }

    // query database
    function query(queryObj){
        var dataset_id = $('#select_dataset').val(),
            subtype_id = $("#select_subtype").val() || "all",
            is_preprocessed = (queryObj.is_predefined === true);
        ARGUMENTS = {
            dataset_ids: [dataset_id],
            trna: [queryObj.trna],
            analyses: {
                trna_expr: true,
                tm_comparison: false,
                survival: false,
                diff_subtype: false
            },
            subtype_id: subtype_id,
            sample_indices: []
        };
        $("input[name='selected_analysis']:checked").each(function(){
            ARGUMENTS.analyses[$(this).val()] = true;
        });
        JOB = {
            type: 'job',
            status: 'queued',
            arguments: ARGUMENTS,
            is_predefined: queryObj.is_predefined,
            is_preprocessed: is_preprocessed,
            results: {}
        };
        if(is_preprocessed === true){
            $("#progressbar").show();
            hideAnalysesTabs();
            showAllAnalysesTabs();
            setTimeout(function(){
                updateLoadingProgress();
            }, 1000);
            IS_JOB_RUNNING = true;
            for (var analysis in ARGUMENTS.analyses) {
                if (ARGUMENTS.analyses.hasOwnProperty(analysis)) {
                    if (ARGUMENTS.analyses[analysis] === true) {
                        getAnalysisData(analysis);
                    }
                }
            }
        }
    }

    // --------------------------------------------------------------
    // Progress
    // init time out and dialog timeout alert
    function initTimeoutDialog() {
        var progressbar = $("#progressbar"),
            progressLabel = $(".progress-label"),
            initProgressLabel = 'Processing...';
            TIMEOUT_DIALOG = $('#timeout-alert').dialog({
            resizable: false,
            autoOpen: false,
            modal: true,
            buttons: {
                "Continue": function () {
                    $(this).dialog('close');
                    TIMEOUT_STOP = false;
                    IS_ANALYSIS_TIMEOUT = false;
                    for (var key in analysisTimeout) {
                        if (analysisTimeout.hasOwnProperty(key)) {
                            // console.log(key);
                            analysisTimeout[key] = 0;
                        }
                    }
                },
                "Stop": function () {
                    $(this).dialog('close');
                    progressbar.hide();
                    gNCompletedAnalyses = {};
                    progressbar.progressbar("value", false);
                    progressLabel.text(initProgressLabel);
                    IS_JOB_RUNNING = false;
                    TIMEOUT_STOP = true;
                }
            }
        });
    }

     // process the submit
    function proceedSubmit() {
        gNCompletedAnalyses = {};
        if ($("#snorna-div").hasClass('has-success')) {
            var trna = $("#snorna").val();
            query({trna: trna, is_predefined: true});
        }
        else {
            alert("Invalid tRNA input");
        }
    }

    // init job check and dialog job running alert
    function initJobCheckDialog() {
        JOB_RUNNING_DIALOG = $("#job-running-alert").dialog({
            resizable: false,
            autoOpen: false,
            modal: true,
            buttons: {
                "Continue": function () {
                    $(this).dialog('close');
                },
                "Submit": function () {
                    $(this).dialog('close');
                    proceedSubmit();
                }
            }
        });
    }

    // progress bar
    function proc_progress() {
        var progressbar = $("#progressbar"),
            progressLabel = $(".progress-label"),
            initProgressLabel = 'Processing...';
        progressbar.progressbar({
            value: false,
            create: function (event, ui) {
                progressLabel.text(initProgressLabel);
            },
            change: function () {
                var progressbarValue = progressbar.progressbar("value");
                if (progressbarValue !== false) {
                    progressLabel.text(progressbarValue.toFixed() + "%");
                }
            },
            complete: function () {
                progressLabel.text("Complete!");
                setTimeout(function () {
                               progressbar.hide();
                               progressLabel.text(initProgressLabel);
                               gNCompletedAnalyses = {};
                               progressbar.progressbar("value", false);
                               progressLabel.text(initProgressLabel);
                               IS_JOB_RUNNING = false;
                           },
                           1000);
            }
        });
        progressbar.height(40);
    }

    // submit form
    function clickSubmit() {
        // /* for analysis
        $("#analysis-submit-button").click(function () {
            if (validateQuery()) {
                queryAnalysis();
            }
        });

        $("#submit-button").click(function () {
            if (IS_JOB_RUNNING) {
                JOB_RUNNING_DIALOG.dialog("open");
            } else {
                proceedSubmit();
            }
        });
    }

    // --------------------------------------------------------------
    // on ready basic

    // clear validation styles
    function clearValidationStyles(obj) {
        var $parent = $(obj).parent();
        $parent.children('label').text('');
        $parent.removeClass('has-error').removeClass('has-success');
        $parent.children('span')
            .removeClass('glyphicon-remove-sign')
            .removeClass('glyphicon-ok-sign');
    }

    // show success to query
    function showSuccess(obj, msg) {
        clearValidationStyles(obj);
        var $parent = $(obj).parent();
        $parent.addClass('has-success');
        $parent.children('span').addClass('glyphicon-ok-sign');
        $parent.children('label').text(msg);
    }

    // show errors
    function showError(obj, msg) {
        clearValidationStyles(obj);
        var $parent = $(obj).parent();
        $parent.addClass('has-error');
        $parent.children('span').addClass('glyphicon-remove-sign');
        $parent.children('label').text('Error: ' + msg);
    }

    // search autocomplete
    function check_input_autocomplete(){
        $("#snorna").autocomplete({
            autoFocus: true,
            source: function(request, response){
                var url = '/tRic/api/trna_list/' + request.term.trim();
                $.getJSON(
                    url,
                    function(data){
                        response(data);
                    }
                );
            },
            select: function(event, ui){
                showSuccess(this);
            }
        });
    }


    // check input in backend
    function checkAnnotationInput(annotation, obj, url) {
        url=  url || '/tRic/api/trna/';
        $.getJSON(url+annotation, function(data){
            if(data.length > 0){
                showSuccess(obj,'');
            }else{
                showError(obj, 'No match for ['+ annotation +']')
            }
        });
    }

    // keyup to check input
    function addAnnotationInputKeyupHandler(){
        var $snorna = $("#snorna");
        $snorna.keyup(function () {
            clearValidationStyles(this);
            var snorna = this.value.trim();
            if (snorna !== '') {
                checkAnnotationInput(snorna.toLowerCase(), this);
            }
        });
    }

    // toggle data datatable
    function toggleDataTableRow() {
        function format(table_id, data) {
            var img = "/tRic/trna/" + table_id + "/png/" + data.encode;
            switch(table_id){
                case "diff_subtype_table":
                    img = [img, data.subtype].join(".");
                    break;
                case "corr_geneexpr_table":
                    img = [img, data.gene_symbol].join(".");
                    break;
                case "corr_rppa_table":
                    img = [img, data.protein].join(".");
                    break;
                case "methylation_table":
                    img = [img, data.meth_id].join(".");
                    break;
                case "diff_subtype_bygene_table":
                    img = [img, data.snorna, data.subtype].join(".");
                    break;
                case "survival_bygene_table":
                    img = [img, data.snorna].join(".");
                    break;
                case "corr_geneexpr_bygene_table":
                    img = [img, data.snorna].join(".");
                    break;
                case "corr_rppa_bygene_table":
                    img = [img, data.snorna].join(".");
                    break;
                case "corr_cnv_bygene_table":
                    img = [img, data.snorna].join(".");
                    break;
                case "methylation_bygene_table":
                    img = [img, data.snorna, data.meth_id].join(".");
                    break;
            }

            return '<div class="slider row">'+
                    '<div class="thumbnail">' +
                    '<img src="'+ img +'" style="width:80%;height:80%">'+
                    '</div>' +
                    '</div>'
        }
        $('#analyses').on('click', 'td.details-control', function () {
            var table_id = $(this).closest('table').attr('id');
            var tr  = $(this).closest('tr');
            var row = OTABLES[table_id].row(tr);
            if (row.child.isShown()) {
                $('div.slider', row.child()).slideUp( function () {
                    row.child.hide();
                    tr.removeClass('shown');
                } );
            }
            else {
                row.child( format(table_id, row.data()), 'no-padding' ).show();
                tr.addClass('shown');
                $('div.slider', row.child()).slideDown();
            }
        });
    }

    return {
        init: function(){
            // init
            reset();
            $("#tabs").tab();
            general_effect();
            load_subtype();

            // progress bar
            initTimeoutDialog();
            initJobCheckDialog();
            proc_progress();

            // submit
            clickSubmit();
        },
        onReadyBasic: function(){

            $("#select_analysis_diff_subtype").on("click",function(event){
                    if($("#select_analysis_diff_subtype").is(":checked")){
                        $("#select_subtype option:selected").prop(
                            "selected", false
                        );
                        $("#select_subtype option[name='all']").prop(
                            "selected",
                            true
                        );
                    }
                });
            $("#select_subtype").on("change",function(event){
                    if(this.value !== "all"){
                        $("#select_analysis_diff_subtype").prop('checked', false);
                    }
                });

            check_input_autocomplete();
            addAnnotationInputKeyupHandler();
            toggleDataTableRow();

        },
        onReadyAnalysis: function(){
            toggleDataTableRow();
            analysis_gene_symbol_input_keyup_handler();
            inputQueryAutoComplete('#gene-input');
        },
        onReadyDatasets: function(){
            load_dataset();
        }
    }
})();

$(function(){
    tric.init();
    switch (window.location.pathname){
        case "/tRic/statistics/":
            tric.onReadyDatasets();
            break;
        case "/tRic/trna/":
            tric.onReadyBasic();
            break;
        case "/tRic/freq/":
            tric.onReadyAnalysis();
            break;
    }
});
