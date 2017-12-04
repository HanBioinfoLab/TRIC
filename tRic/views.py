from django.shortcuts import render

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