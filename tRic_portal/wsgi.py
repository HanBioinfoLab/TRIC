"""
WSGI config for tRic_portal project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.9/howto/deployment/wsgi/
"""

import os

from os.path import join, dirname, abspath
PROJECT_DIR = dirname(dirname(abspath(__file__)))
import sys
sys.path.insert(0,PROJECT_DIR)

from django.core.wsgi import get_wsgi_application

# os.environ.setdefault("DJANGO_SETTINGS_MODULE", "tRic_portal.settings")
os.environ['DJANGO_SETTINGS_MODULE'] = "tRic_portal.settings"
application = get_wsgi_application()
