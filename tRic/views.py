from django.shortcuts import render
from django.http import JsonResponse, HttpResponse

# Load modules
import os
import json
import commands
import subprocess
import pickle
import re


# reosurces and rscritps

rcommand = commands.getoutput("which Rscript")
root_path = os.path.dirname(os.path.abspath(__file__))
rscript_dir = os.path.join(root_path, 'rscripts')
resource_jons = os.path.join(root_path, 'resource', 'jsons')
resource_pngs = os.path.join(root_path, 'resource', 'pngs')
resource_data = os.path.join(root_path, 'resource', 'data')

# Create your views here.

# main home page
def index(request):
    title = "tRic"
    context = {"title": title}

    return render(request, "tric/index.html", context, status=200)

def contact(request):
    title = "Contact"
    context = {"title": title}

    return render(request=request, template_name="tric/contact.html", context=context, status=200)

def methods(request):
    title = "Methods"
    context = {"title": title}

    return render(request=request, template_name="tric/methods.html", context=context, status=200)

def statistics(request):
    title = "Statistics"
    context = {"title": title}

    return render(request=request, template_name="tric/statistics.html", context=context, status=200)

def trna(request):
    title = "tRNA"
    context = {"title": title}

    return render(request=request, template_name="trna/trna.html", context=context, status=200)

# trna expression
def trna_expr_table(request):
    title = "tRNA | tRNA expression"
    context = {"title": title}

    return render(request=request, template_name='trna/datatable/trna_expr_table.html', context=context)

# tumor vs. normal
def tm_comparison_table(request):
    title = "tRNA | tm comparison"
    context = {"title": title}

    return render(request=request, template_name='trna/datatable/tm_comparison_table.html', context=context)

def tm_comparison_table_png(request, png_name):
    png_file = os.path.join(resource_pngs, png_name)
    if os.path.exists(png_file):
        with open(png_file) as f:
            return HttpResponse(f.read(), content_type="image/png")
    else:
        return HttpResponse("Not engough samples!", content_type="text/plain")



# apis
def api_summary(request):
    title = "API | Summary"
    context = {"title": title}

    json_file = os.path.join(resource_data, "summary.json")
    data = json.load(open(json_file, "r"))
    return JsonResponse(data, safe=False)

def api_subtype(request, dataset_id):
    title = "API | Subtype"
    context = {"title": title}

    rscript = os.path.join(rscript_dir, "api_subtype.R")
    cmd = [rcommand, rscript, root_path, dataset_id]
    json_file = os.path.join(resource_jons, "api_subtype." + dataset_id + ".json")
    if not os.path.exists(json_file):
        subprocess.check_output(cmd, universal_newlines=True)

    data = json.load(open(json_file, "r"))
    return JsonResponse(data, safe=False)

def api_trna_list(request, search):
    title = "API | tRNA list"
    context = {"title": title}
    snorna_file = os.path.join(resource_data, "snorna_list.pickle")
    snorna_list = pickle.load(open(snorna_file, "rb"))
    regex = re.compile(search, re.IGNORECASE)
    data = filter(regex.search, snorna_list)[0:10]
    return JsonResponse(data, safe=False)

def api_trna(request, search):
    title = "API | tRNA"
    context = {"title": title}
    snorna_file = os.path.join(resource_data, "snorna_list.pickle")
    snorna_list = pickle.load(open(snorna_file, "rb"))
    regex = re.compile(search)
    data = filter(regex.match, snorna_list)[0:10]
    return JsonResponse(data, safe=False)

def api_trna_expr(request):
    title  = "API | tRNA expression"
    context = {"title": title}

    # request get
    dsid = request.GET["dataset_ids"]
    stid = request.GET["subtype_id"]
    q = request.GET["genes"]

    # for r running
    rscript = os.path.join(rscript_dir, "api_trna_expr.R")
    cmd = [rcommand, rscript, root_path, dsid, stid, q]
    json_file = os.path.join(resource_jons, ".".join(["api_trna_expr", dsid, stid, q, "json"]))
    if not os.path.exists(json_file):
        subprocess.check_output(cmd, universal_newlines=True)

    data = json.load(open(json_file, "r"))
    return JsonResponse(data, safe=False)

def api_tm_comparison(request):
    title = "API | Tumor vs. Normal"
    context = {"title": title}

    # request get
    dsid = request.GET["dataset_ids"]
    stid = request.GET["subtype_id"]
    q = request.GET["genes"]

    png_name = ".".join(["tm_comparison", dsid, stid, q, "png"])

    data = {"png_name": png_name}
    return JsonResponse(data, safe=False)