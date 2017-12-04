from django.shortcuts import render
from django.http import JsonResponse

# Load modules
import os
import json
import commands


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





# apis
def api_summary(request):
    title = "API | summary"
    context = {"title": title}

    json_file = os.path.join(resource_data, "summary.json")
    data = json.load(open(json_file, "r"))
    return JsonResponse(data, safe=False)
