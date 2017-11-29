from django.shortcuts import render

# Create your views here.

# main home page
def index(request):
    title = "tRic"
    context = {"title": title}

    return render(request=request, template_name="tric/index.html" , context= context, status=200)
