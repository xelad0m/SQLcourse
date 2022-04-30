from django.db import models
from django.contrib.auth.models import User                             # отношение Пользователь (встроена в ОРМ)

class Category(models.Model):                                           # отношение Категория
    name = models.CharField(max_length=100)

class Product(models.Model):                                            # отношение Товар
    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.IntegerField(default=0)            
    category = models.ManyToManyField(Category)                         # самостоятельно создает промежуточную таблицу

class Basket(models.Model):                                             # отношение Корзина
    user = models.OneToOneField(User, on_delete=models.CASCADE)         # создает внешний ключ в флагом Уникальный (on_delete обязательный аргумент)
    products = models.ManyToManyField(Category, null=True)              # еще одна промежуточная таблица неявно заданы тут 
    total_sum = models.DecimalField(max_digits=10, decimal_places=2)

# $ django-admin startproject online_store_example

# settings.py -> INSTALLED_APPS = [...    'online_store_example',]      указание, задействовать данный файл models.py
# $ ./manage.py makemigrations online_store_example                     создает непривязанные к СУБД инструкции для отображения текущего состояния моделей
# $ ./manage.py migrate                                                 используя миграции приводит базу данных, указанную в settings.py к виду актуальному models.py

# $ sqlite
# sqlite> чето типа .schema online_store_example_product_category       но у меня не сработало    
# вместо этого можно посмотреть в DB viewer:
# CREATE TABLE "online_store_example_product_category" (
#       "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, 
#       "product_id" bigint NOT NULL REFERENCES "online_store_example_product" ("id") DEFERRABLE INITIALLY DEFERRED, 
#       "category_id" bigint NOT NULL REFERENCES "online_store_example_category" ("id") DEFERRABLE INITIALLY DEFERRED)

# короче вообще не так, как в уроке -> все хуйня, всех расстрелять
