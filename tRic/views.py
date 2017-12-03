from django.shortcuts import render

# Create your views here.

# main home page
def index(request):
    title = "tric"
    context = {"title": title}

    return render(request, "tric/index.html", context, status=200)
