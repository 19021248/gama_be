<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Topic extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'content',
        'cate_id',
        'created_by',
        'status'
    ];

    public function users()
    {
        return $this->belongsTo(User::class, 'created_by', 'id');
    }
}
