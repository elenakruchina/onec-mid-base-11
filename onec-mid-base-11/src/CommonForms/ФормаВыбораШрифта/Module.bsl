///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Шрифт_Arial(Команда)
	
	Закрыть("Arial");
	
КонецПроцедуры

&НаКлиенте
Процедура Шрифт_Verdana(Команда)
	
	Закрыть("Verdana");
	
КонецПроцедуры

&НаКлиенте
Процедура Шрифт_TimesNewRoman(Команда)
	
	Закрыть("Times New Roman");
	
КонецПроцедуры

&НаКлиенте
Процедура Другой(Команда)
	
	Закрыть(-1);
	
КонецПроцедуры

&НаКлиенте
Процедура ШрифтПоУмолчанию(Команда)
	
	НовыйТабличныйДокумент = Новый ТабличныйДокумент;
	Шрифт = НовыйТабличныйДокумент.Область(1,1,1,1).Шрифт; 
	Закрыть(Шрифт.Имя);
	
КонецПроцедуры

#КонецОбласти
